import requests
from fastapi.middleware.cors import CORSMiddleware
from minio import Minio
from elasticsearch import Elasticsearch
import pdfplumber
import json
import io
from docx import Document
from datetime import datetime
from contextlib import asynccontextmanager
from fastapi import FastAPI, Query, Response
import pandas as pd
from typing import List, Dict
from minio.error import S3Error


# Lifespan event handler
@asynccontextmanager
async def lifespan(app: FastAPI):
    """Lifespan event handler to execute startup tasks."""
    await index_all_files()  # Automatically index all files in MinIO on startup
    yield  # Keep the application running

# Initialize FastAPI with lifespan
app = FastAPI(lifespan=lifespan)

# Enable CORS (for frontend integration)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Change this in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Fetch articles from Drupal Headless API
@app.get("/articles")
async def get_articles():
    url = "http://drupal/jsonapi/node/article"  # Fetch all articles
    headers = {"Accept": "application/vnd.api+json"}

    response = requests.get(url, headers=headers)

    if response.status_code != 200:
        return {"error": "Failed to fetch articles", "status_code": response.status_code}

    try:
        drupal_data = response.json()
        articles = drupal_data.get("data", [])

        if not articles:
            return {"message": "No articles found"}

        formatted_articles = [
            {
                "id": article.get("id", "N/A"),
                "title": article.get("attributes", {}).get("title", "No Title"),
                "body": article.get("attributes", {}).get("body", {}).get("value", "No Content"),
            }
            for article in articles
        ]

        return {"articles": formatted_articles}

    except requests.exceptions.JSONDecodeError:
        return {"error": "Invalid JSON response", "raw_response": response.text}
    


# MinIO Client
minio_client = Minio(
    "minio:9000",  # ✅ Ensure this is the API port, NOT the console port (9090)
    access_key="minioadmin",  # ✅ Check if credentials match your MinIO setup
    secret_key="minioadmin",
    secure=False
)

BUCKET_NAME = "mybucket"

# Elasticsearch Client
es = Elasticsearch("http://elasticsearch:9200")


# ✅ Metadata Extraction Functions (Integrated)
def parse_text_metadata(text: str):
    """Extract metadata from plain text, ensuring no empty keys."""
    metadata = {}
    lines = text.split("\n")

    for line in lines:
        parts = line.split(":", 1)
        if len(parts) == 2:
            key, value = parts
            key, value = key.strip(), value.strip()
            if key:  # ✅ Ignore empty keys
                metadata[key] = value

    return metadata


def parse_excel_metadata(df):
    """Extract metadata from an Excel table, ensuring no empty keys."""
    metadata = {}

    for index, row in df.iterrows():
        if len(row) >= 2:
            key, value = str(row[0]).strip(), str(row[1]).strip()
            if key:  # ✅ Ignore empty keys
                metadata[key] = value

    return metadata


def extract_pdf_table_metadata(pdf):
    """Extract metadata from a structured table inside a PDF, ensuring correct key-value mapping."""
    table_metadata = {}

    for page in pdf.pages:
        tables = page.extract_tables()
        for table in tables:
            for row in table:
                # Ensure row has exactly three columns (S. No., Data Elements, Values)
                if len(row) >= 3:
                    key = row[1].strip() if row[1] else None  # Extract 'Data Elements' column
                    value = row[2].strip() if row[2] else None  # Extract 'Values' column

                    if key and value:  # Ensure valid key-value pairs
                        table_metadata[key] = value

    return table_metadata


def extract_excel_metadata(file_data: bytes):
    """Extracts metadata from an Excel sheet named 'Metadata' and returns it in the required format."""
    metadata = {}

    try:
        xls = pd.ExcelFile(io.BytesIO(file_data))
        print("Available sheets:", xls.sheet_names)  # Debug: Print available sheets

        if "Metadata" not in xls.sheet_names:
            print("❌ Sheet 'Metadata' not found! Check the sheet names in the Excel file.")
            return {}

        df = pd.read_excel(xls, sheet_name="Metadata", header=None)
        print("🔹 DataFrame read successfully:")
        print(df.head())  # Debug: Print first few rows

        if df.empty or df.shape[1] < 3:  # Ensure at least 3 columns exist
            print("❌ Sheet is empty or does not have enough columns.")
            return {}

        # Skip the first row if it contains headers (like "S. No." / "Data Elements / Values")
        if "S. No." in str(df.iloc[0, 0]) and "Data Elements" in str(df.iloc[0, 1]):
            df = df.iloc[1:]  # Skip first row
            print("🔹 Skipped first row (header detected)")

        # Extract key-value pairs from columns 1 and 2 (Data Elements and Values)
        for _, row in df.iterrows():
            key = str(row[1]).strip()  # Column 1: Data Elements
            value = str(row[2]).strip()  # Column 2: Values

            if key:  # Ensure the key is not empty
                metadata[key] = value

        print("✅ Extracted metadata:", metadata)
        return metadata

    except Exception as e:
        print(f"❌ Error reading Excel file: {e}")
        return {}


def extract_metadata_from_file(file_data: bytes, filename: str):
    """Extract metadata from PDF, Excel, and DOCX files and remove empty keys."""
    metadata = {}

    if filename.endswith(".pdf"):
        with pdfplumber.open(io.BytesIO(file_data)) as pdf:
            # Extract text-based metadata
            text = "\n".join([page.extract_text() for page in pdf.pages if page.extract_text()])
            metadata = parse_text_metadata(text)

            # Extract structured table metadata
            table_metadata = extract_pdf_table_metadata(pdf)

            # Merge extracted metadata
            metadata.update(table_metadata)

    elif filename.endswith(".xlsx"):
        # df = pd.read_excel(io.BytesIO(file_data))
        # with open(filename, "rb") as f:
        #      file_data = f.read()
        file_data = minio_client.get_object(BUCKET_NAME, filename.strip()).read()
        metadata = extract_excel_metadata(file_data) 
        #metadata = extract_excel_metadata(df)

    elif filename.endswith(".docx"):
        doc = Document(io.BytesIO(file_data))
        text = "\n".join([para.text for para in doc.paragraphs])
        metadata = parse_text_metadata(text)

    metadata["filename"] = filename

    # ✅ Extract and use meaningful metadata fields
    metadata["filename"] = filename.lower()
    metadata["status"] = metadata.get("Present Status", "Unknown").lower()
    metadata["language"] = metadata.get("Language", "Unknown").lower()

    # ✅ Remove empty keys
    metadata = {k: v for k, v in metadata.items() if k.strip()}

    return metadata


# ✅ Indexing Files from MinIO into Elasticsearch
async def index_all_files():
    """Index all files from MinIO into Elasticsearch."""
    try:
        objects = minio_client.list_objects(BUCKET_NAME, recursive=True)
        indexed_files = []

        for obj in objects:
            filename = obj.object_name
            response = minio_client.stat_object(BUCKET_NAME, filename)
            last_modified = response.last_modified.isoformat()

            file_data = minio_client.get_object(BUCKET_NAME, filename).read()
            metadata = extract_metadata_from_file(file_data, filename)
            metadata["date"] = last_modified

            # ✅ Ensure metadata is valid before indexing
            if metadata:
                es.index(index="documents", id=filename, body=metadata)
                indexed_files.append(filename)

        return {"message": f"Indexed {len(indexed_files)} files", "files": indexed_files}
    except Exception as e:
        return {"error": str(e)}


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Lifespan event to index files at startup."""
    await index_all_files()  # ✅ Index files when FastAPI starts
    yield




@app.get("/index_all/")
async def trigger_index_all():
    """Manually trigger indexing of all files"""
    return await index_all_files()


@app.post("/index")
async def index_document(document: dict):
    """Index a single document into Elasticsearch."""
    
    # ✅ Ensure there are no empty keys in the document
    document = {k: v for k, v in document.items() if k.strip()}

    if not document:
        return {"error": "Document contains only empty keys"}

    es.index(index="documents", body=document)
    return {"message": "Document indexed"}


@app.get("/filter-documents/")
async def filter_documents(
    status: str = Query(None),
    publisher: str = Query(None),
    year_of_publish: str = Query(None),
    document_type: str = Query(None),
    enforcement: str = Query(None),
    creator: str = Query(None),
    contributor: str = Query(None),
    target_audience: str = Query(None),
    format: str = Query(None),
    language: str = Query(None),
    coverage: str = Query(None),
):
    """Filter documents based on metadata fields."""
    es_query = {"bool": {"must": [], "filter": []}}

    filters = {
        "Present Status": status,  # Use exact field name from mapping
        "Publisher": publisher,
        "Year of Release": year_of_publish,
        "Type of Standard Document": document_type,
        "Enforcement Category": enforcement,
        "Creator": creator,
        "Contributor": contributor,
        "Target Audience": target_audience,
        "Format": format,
        "Language": language,
        "Coverage: Spatial": coverage,
    }

    for key, value in filters.items():
        if value:
            es_query["bool"]["must"].append({"match": {key: value}})  # Using match instead of term

    print("Elasticsearch Query:", json.dumps(es_query, indent=4))  # Debugging

    response = es.search(index="documents", body={"query": es_query})

    documents = [
        hit["_source"].get("filename", "Unknown") for hit in response["hits"]["hits"]
    ]

    return {"message": "Filter function works!", "documents": documents}


@app.get("/search-documents/")
async def search_documents(tag_key: str, tag_value: str):
    """
    Search for PDF documents in MinIO based on tag values.
    """
    matching_files = []

    # List all objects in the bucket
    objects = minio_client.list_objects(BUCKET_NAME, recursive=True)

    for obj in objects:
        try:
            # Get tags for each object
            tags = minio_client.get_object_tags(BUCKET_NAME, obj.object_name)
            if tags and tags.get(tag_key) == tag_value:
                matching_files.append({
                    "file_name": obj.object_name,
                    "size": obj.size,
                    "last_modified": obj.last_modified.strftime("%Y-%m-%d %H:%M:%S"),
                    "etag": obj.etag,
                    "tags": tags
                })
        except:
            continue  # Skip objects without tags

    if not matching_files:
        return {"message": "No documents found with the given tag."}

    return {"matching_documents": matching_files}


@app.get("/list-files", response_model=List[str])
def list_files():
    """API route to list all files in the MinIO bucket."""
    try:
        objects = minio_client.list_objects(BUCKET_NAME, recursive=True)
        file_list = [obj.object_name for obj in objects]
        return file_list
    except Exception as e:
        return {"error": str(e)}


@app.get("/list-files-with-tags", response_model=Dict[str, Dict[str, str]])
async def list_files_with_tags():
    """
    List all files in MinIO with their tags.
    """
    files_with_tags = {}

    try:
        # Get list of all files
        objects = minio_client.list_objects(BUCKET_NAME, recursive=True)

        for obj in objects:
            try:
                # Fetch object tags
                tags = minio_client.get_object_tags(BUCKET_NAME, obj.object_name)
                
                # Store filename with its tags
                files_with_tags[obj.object_name] = tags if tags else {}

            except S3Error as e:
                print(f"Error fetching tags for {obj.object_name}: {str(e)}")

    except S3Error as e:
        return {"error": str(e)}

    return files_with_tags


@app.get("/download-file/{file_name}")
async def download_file(file_name: str):
    """
    Download a file from MinIO and return it as a response.
    """
    try:
        # Get the file from MinIO
        file_obj = minio_client.get_object(BUCKET_NAME, file_name)
        
        # Read the file data
        file_data = file_obj.read()

        # Return the file as a response
        return Response(content=file_data, media_type="application/octet-stream",
                        headers={"Content-Disposition": f'attachment; filename="{file_name}"'})

    except S3Error as e:
        return {"error": str(e)}
