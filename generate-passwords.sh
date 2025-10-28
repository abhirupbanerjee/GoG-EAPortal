#!/bin/bash

# ============================================
# COMPREHENSIVE PASSWORD GENERATOR
# GoG-EAPortal - All Services
# ============================================
# This script generates secure passwords for ALL services in your .env file

set -e

echo "🔐 Generating Secure Credentials for GoG-EAPortal"
echo "================================================================"
echo ""
echo "Generating passwords for:"
echo "  • MinIO (Object Storage)"
echo "  • MySQL/MariaDB (Drupal Database)"
echo "  • PostgreSQL (Backend/Login Database)"
echo "  • Traefik Dashboard"
echo "  • Backend JWT Authentication"
echo "  • Wiki.js Database"
echo "  • Paperless-ngx Stack"
echo ""
echo "Please wait..."
echo ""

# ============================================
# EXISTING SERVICES
# ============================================

# MinIO Credentials
MINIO_ROOT_USER="minioadmin"
MINIO_ROOT_PASSWORD=$(openssl rand -base64 24 | tr -d /=+ | cut -c1-32)

# MySQL/MariaDB (Drupal)
MYSQL_ROOT_PASSWORD=$(openssl rand -base64 24 | tr -d /=+ | cut -c1-32)
MYSQL_PASSWORD=$(openssl rand -base64 24 | tr -d /=+ | cut -c1-32)
MYSQL_USER="drupal"
MYSQL_DATABASE="drupal"

# PostgreSQL (Backend/Login)
POSTGRES_USER="postgres"
POSTGRES_PASSWORD=$(openssl rand -base64 24 | tr -d /=+ | cut -c1-32)
POSTGRES_DB="postgres"
DB_PASSWORD=$(openssl rand -base64 24 | tr -d /=+ | cut -c1-32)

# Traefik Dashboard (htpasswd format)
TRAEFIK_USER="admin"
TRAEFIK_PLAIN_PASSWORD=$(openssl rand -base64 16 | tr -d /=+ | cut -c1-24)
# Generate htpasswd hash for Traefik
TRAEFIK_DASHBOARD_PASSWORD=$(openssl passwd -apr1 "$TRAEFIK_PLAIN_PASSWORD")

# Backend JWT Authentication
SECRET_KEY=$(openssl rand -hex 32)
ALGORITHM="HS256"
ACCESS_TOKEN_EXPIRE_MINUTES="30"

# ============================================
# NEW SERVICES (Wiki.js & Paperless-ngx)
# ============================================

# Wiki.js Database
WIKI_DB_USER="wikijs"
WIKI_DB_PASSWORD=$(openssl rand -base64 24 | tr -d /=+ | cut -c1-32)
WIKI_DB_NAME="wiki"

# Paperless-ngx Database
PAPERLESS_DBUSER="paperless"
PAPERLESS_DBPASS=$(openssl rand -base64 24 | tr -d /=+ | cut -c1-32)
PAPERLESS_DBNAME="paperless"

# Paperless Admin User
PAPERLESS_ADMIN_USER="admin"
PAPERLESS_ADMIN_PASSWORD=$(openssl rand -base64 16 | tr -d /=+ | cut -c1-24)

# Paperless Secret Key (50 characters)
PAPERLESS_SECRET_KEY=$(openssl rand -base64 50 | tr -d /=+ | cut -c1-50)

echo "✅ Password Generation Complete!"
echo ""
echo "================================================================"
echo "📋 COPY THESE VALUES TO YOUR .env.dev FILE"
echo "================================================================"
echo ""

# ============================================
# OUTPUT SECTION
# ============================================

cat << EOF
# ============================================
# EXISTING SERVICES CREDENTIALS
# ============================================

# MinIO Configuration
MINIO_ROOT_USER=$MINIO_ROOT_USER
MINIO_ROOT_PASSWORD=$MINIO_ROOT_PASSWORD

# Drupal/MySQL Configuration
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
MYSQL_DATABASE=$MYSQL_DATABASE
MYSQL_USER=$MYSQL_USER
MYSQL_PASSWORD=$MYSQL_PASSWORD

# PostgreSQL (Backend Login System)
POSTGRES_USER=$POSTGRES_USER
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
POSTGRES_DB=$POSTGRES_DB
DB_PASSWORD=$DB_PASSWORD

# Backend JWT Authentication
SECRET_KEY=$SECRET_KEY
ALGORITHM=$ALGORITHM
ACCESS_TOKEN_EXPIRE_MINUTES=$ACCESS_TOKEN_EXPIRE_MINUTES

# Traefik Dashboard
TRAEFIK_DASHBOARD_USER=$TRAEFIK_USER
TRAEFIK_DASHBOARD_PASSWORD=$TRAEFIK_DASHBOARD_PASSWORD

# ============================================
# NEW SERVICES CREDENTIALS
# ============================================

# Wiki.js Database
WIKI_DB_USER=$WIKI_DB_USER
WIKI_DB_PASSWORD=$WIKI_DB_PASSWORD
WIKI_DB_NAME=$WIKI_DB_NAME

# Paperless-ngx Database
PAPERLESS_DBUSER=$PAPERLESS_DBUSER
PAPERLESS_DBPASS=$PAPERLESS_DBPASS
PAPERLESS_DBNAME=$PAPERLESS_DBNAME

# Paperless Admin User
PAPERLESS_ADMIN_USER=$PAPERLESS_ADMIN_USER
PAPERLESS_ADMIN_PASSWORD=$PAPERLESS_ADMIN_PASSWORD

# Paperless Secret Key
PAPERLESS_SECRET_KEY=$PAPERLESS_SECRET_KEY

EOF

echo ""
echo "================================================================"
echo "📝 IMPORTANT ACCESS CREDENTIALS"
echo "================================================================"
echo ""
echo "🔑 Service Login Information:"
echo ""
echo "1️⃣  MinIO Console (https://minio-console.gea.abhirup.app)"
echo "   Username: $MINIO_ROOT_USER"
echo "   Password: $MINIO_ROOT_PASSWORD"
echo ""
echo "2️⃣  Traefik Dashboard (https://traefik.gea.abhirup.app)"
echo "   Username: $TRAEFIK_USER"
echo "   Password: $TRAEFIK_PLAIN_PASSWORD"
echo ""
echo "3️⃣  Paperless-ngx (https://dms.gea.abhirup.app)"
echo "   Username: $PAPERLESS_ADMIN_USER"
echo "   Password: $PAPERLESS_ADMIN_PASSWORD"
echo ""
echo "4️⃣  Wiki.js (https://wiki.gea.abhirup.app)"
echo "   Note: Create admin account during first-time setup wizard"
echo ""
echo "5️⃣  pgAdmin (https://db.gea.abhirup.app)"
echo "   Email: <your_contact_email>"
echo "   Password: \$POSTGRES_PASSWORD (from above)"
echo ""
echo "================================================================"
echo "⚠️  SECURITY WARNINGS"
echo "================================================================"
echo ""
echo "✅ DO:"
echo "   • Store ALL credentials in a password manager"
echo "   • Keep a secure backup of this output"
echo "   • Change Paperless admin password after first login"
echo "   • Complete Wiki.js setup wizard immediately"
echo ""
echo "❌ DON'T:"
echo "   • Commit .env file to git"
echo "   • Share passwords via email/chat"
echo "   • Use these passwords for other services"
echo "   • Leave default passwords unchanged"
echo ""
echo "================================================================"
echo "🎯 DEPLOYMENT CHECKLIST"
echo "================================================================"
echo ""
echo "[ ] 1. Copy ALL credentials above to .env.dev"
echo "[ ] 2. Save this output in password manager"
echo "[ ] 3. Verify all passwords copied correctly"
echo "[ ] 4. Set CONTACT_EMAIL in .env.dev"
echo "[ ] 5. Run: cp .env.dev .env"
echo "[ ] 6. Run: ./scripts/deploy.sh"
echo "[ ] 7. Complete Wiki.js setup wizard"
echo "[ ] 8. Login to Paperless and change password"
echo "[ ] 9. Test all service logins"
echo "[ ] 10. Delete this script output from terminal history"
echo ""
echo "================================================================"
echo ""
