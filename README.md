# GoG – Government of Grenada Digital Services Portal (GoG-EAPortal)

A containerized platform for managing digital government services.

Tech stack
- Frontend: React
- Backend: FastAPI (Python)
- CMS: Drupal (headless)
- Storage: MinIO (S3-compatible)
- Search: Elasticsearch
- Database: PostgreSQL + pgAdmin
- Orchestration: Docker Compose

---

## Contents of this README
- Quick start (Docker Compose)
- Development (per-service)
- Environment and secrets
- Database seeding / db.sql
- Useful scripts and files
- Troubleshooting
- Recommendations & next steps
- License & contacts

---

## ⚡ Quick Start (recommended for local development)
Prerequisites
- Git
- Docker (Desktop or Engine)
- Docker Compose (v2 recommended — `docker compose` command)
- Optional (for local frontend dev): Node.js + npm/yarn
- Optional (for backend dev): Python 3.10+ and virtualenv/pip

1. Clone this repository
```bash
git clone https://github.com/abhirupbanerjee/GoG-EAPortal.git
cd GoG-EAPortal
```

2. Create a local environment file from the template (see Environment section below) and update values as needed:
```bash
cp .env.dev .env         # DO NOT commit .env
```

3. Build and start all services
```bash
docker compose up --build -d
```

4. Verify services are running (for local only dev only)
- Frontend (React): http://localhost:8081
- Backend (FastAPI): http://localhost:8000
- Drupal (CMS): http://localhost:8001
- MinIO console: http://localhost:9090
- Elasticsearch: http://localhost:9200
- pgAdmin: http://localhost:5050

(These ports are default in README; confirm with docker-compose.yml before using.)

To stop and remove containers:
```bash
docker compose down
```

---

## Development (per-service)
This repository contains multiple components. Use the section below when you want to make changes to one component while keeping others running.

Backend (FastAPI)
- Location: ./backend
- Typical dev workflow:
  ```bash
  cd backend
  python -m venv .venv
  source .venv/bin/activate
  pip install -r ../requirements.txt    # or requirements in backend/ if present
  uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
  ```
- Notes:
  - Ensure environment variables are set (see Environment section).
  - If OpenAPI docs are exposed, they'll usually be at /docs or /redoc.

Frontend (React)
- Location: ./frontend
- Typical dev workflow:
  ```bash
  cd frontend
  npm install
  npm start            # runs dev server (port may differ)
  ```
- Build for production:
  ```bash
  npm run build
  ```

Drupal (Headless CMS)
- Location: ./drupal-docker (or drupal-docker/drupal_t)
- Use the docker-compose setup for local CMS instance. Access the Drupal admin at the configured port (default above).

Other components
- MinIO, Elasticsearch, PostgreSQL, and pgAdmin are run via docker-compose for local dev.

---

## Environment files & secrets (IMPORTANT)
This repository currently contains environment files (.env.dev, .env.pre-prod, .env.prod). Committing real credentials or secrets into the repository is a security risk.

Recommended actions:
- Remove sensitive .env files from the repository immediately.
- Add a `.env.example` or `.env.template` file with placeholder values and add `.env` to `.gitignore`.
- If secrets were committed, rotate credentials and remove them from history (use tools like BFG or git filter-repo).

Typical pattern:
- .env.example (committed, no secrets)
- .env (local, not committed)
- CI/infra secrets stored in a secrets manager

Document the environment variables used by each component (backend, Drupal, MinIO, PostgreSQL, Elasticsearch). The README should list required keys and example values.

---

## Database seeding: db.sql
A large file db.sql exists at the repository root. It appears to be a full SQL dump (size ~10MB). Notes:
- Large SQL dumps inflate repository size — consider storing large dumps in releases or an artifacts store rather than keeping them in git.
- To import locally into PostgreSQL:
  ```bash
  # if using dockerized postgres, you can run:
  docker exec -i <postgres_container> psql -U <user> -d <db> < db.sql
  ```
  or using psql locally:
  ```bash
  psql -h <host> -U <user> -d <db> -f db.sql
  ```

Consider switching to migration-based schema management (Alembic/Flyway/liquibase) if not already in use.

---

## Useful files & scripts
- docker-compose.yml — orchestration for the local environment
- Dockerfile — base image(s)
- uploader.py — Python script for uploading content (document its usage and required env vars)
- infra/ — deployment and nginx setup scripts (e.g., infra/setup-nginx-ip-only.sh, infra/setup-nginx-ssl-gea.sh)
- drupal-docker/ — Drupal container and supporting files
- requirements.txt — Python dependencies (currently very small / likely incomplete; consider pinning and expanding)

---

## Security & repository health observations
- Remove committed .env files with sensitive values and replace with .env.example.
- If secrets were exposed, rotate keys and consider removing them from git history.
- The presence of db.sql in repo root may be intentional for seeding, but consider moving to an artifact store or a separate data repository.
- Add .gitattributes and .gitignore rules to avoid committing large binary files or environment files.

---

## Troubleshooting / common issues
- Docker/Compose errors:
  - Ensure Docker daemon is running and you are using compatible compose command (`docker compose` for v2).
- Port conflicts:
  - If ports are in use (8081, 8000, 8001, 9090, 9200, 5050), stop conflicting local services or change mapping in docker-compose.yml.
- Service health:
  - Check container logs `docker compose logs -f <service>`
  - Check `docker compose ps` for container status.

---

## Recommendations & next steps
1. Replace committed .env.* files with `.env.example` and add `.env` to `.gitignore`.
2. Move large db.sql out of main repository or convert to migration-based schema management.
3. Expand and pin Python dependencies (requirements.txt) and document how to run backend tests.
4. Add CONTRIBUTING.md with developer workflow and a small architecture diagram or ASCII block showing service flow and ports.
5. Add an OpenAPI link or build step to expose backend API docs if available.
6. Add a short script or Makefile for common tasks:
   - make up / make down / make build / make import-db

---

## Contributing
Please open issues or PRs for changes. Add small focused changes (e.g., update docs, add `.env.example`) and keep PR descriptions clear.

---

## License & contacts
Internal project — private use only. For questions contact the repository owner or the project lead.

---