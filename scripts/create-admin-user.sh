#!/bin/bash

# ============================================
# INITIAL ADMIN USER CREATOR
# GoG-EAPortal
# ============================================
# This script creates the first admin user in PostgreSQL

set -e

echo "👤 Creating Initial Admin User"
echo "================================================================"
echo ""

# Get admin details
read -p "Admin Name [Admin User]: " ADMIN_NAME
ADMIN_NAME=${ADMIN_NAME:-"Admin User"}

read -p "Admin Email [admin@gog.gd]: " ADMIN_EMAIL
ADMIN_EMAIL=${ADMIN_EMAIL:-"admin@gog.gd"}

read -s -p "Admin Password: " ADMIN_PASSWORD
echo ""

read -p "Organisation [Government of Grenada]: " ADMIN_ORG
ADMIN_ORG=${ADMIN_ORG:-"Government of Grenada"}

echo ""
echo "Creating admin user with:"
echo "  Name: $ADMIN_NAME"
echo "  Email: $ADMIN_EMAIL"
echo "  Organisation: $ADMIN_ORG"
echo ""

# Check if PostgreSQL container is running
if ! docker ps | grep -q postgres; then
    echo "❌ PostgreSQL container is not running!"
    echo "   Start it with: docker-compose up -d"
    exit 1
fi

# Create Python script to hash password and insert user
docker exec -i postgres python3 << EOF
import psycopg2
from passlib.context import CryptContext
import uuid
from datetime import datetime
import os

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Get database password from environment
db_password = os.getenv('POSTGRES_PASSWORD', 'mysecretpassword')

try:
    conn = psycopg2.connect(
        host="localhost",
        port="5432",
        dbname="postgres",
        user="postgres",
        password=db_password
    )
    cur = conn.cursor()

    admin_id = str(uuid.uuid4())
    password_hash = pwd_context.hash("$ADMIN_PASSWORD")

    cur.execute("""
        INSERT INTO users (user_id, name, email, password_hash, role, organization, created_at, updated_at)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (email) DO NOTHING
    """, (
        admin_id,
        "$ADMIN_NAME",
        "$ADMIN_EMAIL",
        password_hash,
        "admin",
        "$ADMIN_ORG",
        datetime.utcnow(),
        datetime.utcnow()
    ))

    if cur.rowcount > 0:
        conn.commit()
        print("✅ Admin user created successfully!")
    else:
        print("⚠️  User with this email already exists!")

    cur.close()
    conn.close()

except Exception as e:
    print(f"❌ Error creating admin user: {e}")
    exit(1)
EOF

if [ $? -eq 0 ]; then
    echo ""
    echo "================================================================"
    echo "✅ Admin User Created Successfully!"
    echo "================================================================"
    echo ""
    echo "Login Credentials:"
    echo "  Email: $ADMIN_EMAIL"
    echo "  Password: $ADMIN_PASSWORD"
    echo ""
    echo "Login URL: https://gea.abhirup.app (or your frontend URL)"
    echo ""
    echo "⚠️  IMPORTANT:"
    echo "  • Store these credentials securely"
    echo "  • Change password after first login"
    echo "  • Enable 2FA if available"
    echo ""
else
    echo ""
    echo "❌ Failed to create admin user"
    echo "   Check the error message above"
    exit 1
fi