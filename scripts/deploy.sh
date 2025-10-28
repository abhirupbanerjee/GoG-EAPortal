#!/bin/bash

# ============================================
# UNIFIED DEPLOYMENT SCRIPT
# ============================================

set -e

echo "🚀 Starting deployment..."

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ .env file not found!"
    echo "Copy one of the templates:"
    echo "  cp .env.dev .env"
    echo "  cp .env.pre-prod .env"
    echo "  cp .env.prod .env"
    exit 1
fi

# Source domain configuration
source config/domains.sh

# Validate environment
./scripts/validate-env.sh

# Build and start services
echo "🔨 Building containers..."
docker-compose build

echo "🚀 Starting services..."
docker-compose up -d

# Wait for services to be healthy
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check service health
echo "🏥 Health Check:"
docker-compose ps

echo ""
echo "✅ Deployment Complete!"
echo ""
echo "📊 Service URLs:"
echo "   Frontend:      https://${FRONTEND_DOMAIN}"
echo "   API:          https://${API_DOMAIN}"
echo "   CMS:          https://${CMS_DOMAIN}"
echo "   MinIO:        https://${MINIO_DOMAIN}"
echo "   MinIO Console:https://${MINIO_CONSOLE_DOMAIN}"
echo "   Database:     https://${DB_DOMAIN}"
echo "   Search:       https://${SEARCH_DOMAIN}"
echo "   Traefik:      https://${TRAEFIK_DOMAIN}"
echo "   Wiki:         https://${WIKI_DOMAIN}"
echo "   DMS:          https://${DMS_DOMAIN}"
echo ""
echo "🔐 Traefik Dashboard:"
echo "   Username: ${TRAEFIK_DASHBOARD_USER}"
echo "   Password: ${TRAEFIK_DASHBOARD_PASSWORD}"