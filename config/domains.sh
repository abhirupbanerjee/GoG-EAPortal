#!/bin/bash

# ============================================
# DOMAIN RESOLUTION SCRIPT
# ============================================
# Reads DEPLOYMENT_ENV and exports all domain variables
# Source this before running docker-compose

set -e

# Load root .env file
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    echo "Copy one of the templates: .env.dev, .env.pre-prod, or .env.prod to .env"
    exit 1
fi

source .env

# Validate DEPLOYMENT_ENV
if [ -z "$DEPLOYMENT_ENV" ]; then
    echo "❌ Error: DEPLOYMENT_ENV not set in .env file!"
    exit 1
fi

echo "🔧 Environment: $DEPLOYMENT_ENV"

# Domain resolution based on environment
case "$DEPLOYMENT_ENV" in
    dev)
        export BASE_DOMAIN="abhirup.app"
        ;;
    pre-prod)
        export BASE_DOMAIN="xyz"
        ;;
    prod)
        export BASE_DOMAIN="gea.gov.gd"
        ;;
    *)
        echo "❌ Invalid DEPLOYMENT_ENV: $DEPLOYMENT_ENV"
        echo "Valid options: dev, pre-prod, prod"
        exit 1
        ;;
esac

# Generate all domain variables
if [ "$DEPLOYMENT_ENV" = "prod" ]; then
    export FRONTEND_DOMAIN="gea.gov.gd"
else
    export FRONTEND_DOMAIN="gea.${BASE_DOMAIN}"
fi

export API_DOMAIN="api.gea.${BASE_DOMAIN}"
export CMS_DOMAIN="cms.gea.${BASE_DOMAIN}"
export MINIO_DOMAIN="minio.gea.${BASE_DOMAIN}"
export MINIO_CONSOLE_DOMAIN="minio-console.gea.${BASE_DOMAIN}"
export DB_DOMAIN="db.gea.${BASE_DOMAIN}"
export SEARCH_DOMAIN="search.gea.${BASE_DOMAIN}"
export TRAEFIK_DOMAIN="traefik.gea.${BASE_DOMAIN}"
export DBADMIN_DOMAIN="dbadmin.gea.${BASE_DOMAIN}"

# Generate full URLs with https
export FRONTEND_URL="https://${FRONTEND_DOMAIN}"
export API_URL="https://${API_DOMAIN}"
export CMS_URL="https://${CMS_DOMAIN}"
export MINIO_URL="https://${MINIO_DOMAIN}"
export MINIO_CONSOLE_URL="https://${MINIO_CONSOLE_DOMAIN}"

# Generate CORS origins (comma-separated, no spaces)
export CORS_ORIGINS="${FRONTEND_URL},${CMS_URL},${API_URL}"

# Display configuration
echo "✅ Domain Configuration:"
echo "   Frontend:      ${FRONTEND_DOMAIN}"
echo "   API:          ${API_DOMAIN}"
echo "   CMS:          ${CMS_DOMAIN}"
echo "   MinIO:        ${MINIO_DOMAIN}"
echo "   MinIO Console:${MINIO_CONSOLE_DOMAIN}"
echo "   Database:     ${DB_DOMAIN}"
echo "   Search:       ${SEARCH_DOMAIN}"
echo "   Traefik:      ${TRAEFIK_DOMAIN}"
echo ""
echo "📦 Ready for deployment!"