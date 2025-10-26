#!/bin/bash

# ============================================
# ENVIRONMENT SWITCHER SCRIPT
# ============================================
# Usage: ./scripts/set-environment.sh [dev|pre-prod|prod]

set -e

TARGET_ENV=$1

if [ -z "$TARGET_ENV" ]; then
    echo "Usage: ./scripts/set-environment.sh [dev|pre-prod|prod]"
    exit 1
fi

# Validate environment
case "$TARGET_ENV" in
    dev|pre-prod|prod)
        ;;
    *)
        echo "❌ Invalid environment: $TARGET_ENV"
        echo "Valid options: dev, pre-prod, prod"
        exit 1
        ;;
esac

TEMPLATE_FILE=".env.${TARGET_ENV}"

if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "❌ Template file not found: $TEMPLATE_FILE"
    exit 1
fi

echo "🔄 Switching to environment: $TARGET_ENV"

# Backup current .env if exists
if [ -f .env ]; then
    cp .env .env.backup
    echo "✅ Current .env backed up to .env.backup"
fi

# Copy template to .env
cp "$TEMPLATE_FILE" .env
echo "✅ Environment set to: $TARGET_ENV"

# Source domain configuration
source config/domains.sh

# Restart services
echo "🔄 Restarting services with new configuration..."
docker-compose down
docker-compose up -d

echo ""
echo "✅ Environment switch complete!"
echo "📊 Active Configuration:"
echo "   Environment: $TARGET_ENV"
echo "   Frontend:    https://${FRONTEND_DOMAIN}"
echo "   API:         https://${API_DOMAIN}"
echo "   CMS:         https://${CMS_DOMAIN}"
echo "   Traefik:     https://${TRAEFIK_DOMAIN}"