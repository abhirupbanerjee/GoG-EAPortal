#!/bin/bash

# ============================================
# ENVIRONMENT VALIDATION SCRIPT
# ============================================

set -e

echo "🔍 Validating environment configuration..."

# Check required files
REQUIRED_FILES=(".env" "traefik.yml" "docker-compose.yml" "config/domains.sh")

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ Missing required file: $file"
        exit 1
    fi
done

echo "✅ All required files present"

# Load environment
source .env

# Check critical variables
CRITICAL_VARS=(
    "DEPLOYMENT_ENV"
    "MINIO_ROOT_USER"
    "MINIO_ROOT_PASSWORD"
    "LETS_ENCRYPT_EMAIL"
    "TRAEFIK_DASHBOARD_USER"
    "TRAEFIK_DASHBOARD_PASSWORD"
)

for var in "${CRITICAL_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ Missing required variable: $var"
        exit 1
    fi
done

echo "✅ All critical variables set"

# Validate DEPLOYMENT_ENV
case "$DEPLOYMENT_ENV" in
    dev|pre-prod|prod)
        echo "✅ Valid environment: $DEPLOYMENT_ENV"
        ;;
    *)
        echo "❌ Invalid DEPLOYMENT_ENV: $DEPLOYMENT_ENV"
        exit 1
        ;;
esac

# Source domain configuration
source config/domains.sh

echo "✅ Domain configuration valid"
echo ""
echo "📊 Environment Summary:"
echo "   Environment: $DEPLOYMENT_ENV"
echo "   Base Domain: $BASE_DOMAIN"
echo "   Frontend:    $FRONTEND_DOMAIN"
echo ""
echo "✅ Validation passed!"