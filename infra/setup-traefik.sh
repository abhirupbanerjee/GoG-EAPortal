#!/bin/bash

# ============================================
# TRAEFIK INFRASTRUCTURE SETUP
# ============================================

set -e

echo "🔧 Setting up Traefik infrastructure..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root (use sudo)"
    exit 1
fi

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo "📦 Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    usermod -aG docker $SUDO_USER
    rm get-docker.sh
fi

# Install Docker Compose if not present
if ! command -v docker-compose &> /dev/null; then
    echo "📦 Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Create necessary directories
mkdir -p /var/log/traefik
mkdir -p /opt/traefik/acme

# Set permissions for ACME storage
touch /opt/traefik/acme/acme.json
chmod 600 /opt/traefik/acme/acme.json

# Configure firewall (if ufw is installed)
if command -v ufw &> /dev/null; then
    echo "🔥 Configuring firewall..."
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw --force enable
fi

# Generate htpasswd for Traefik dashboard
echo "🔐 Setting up Traefik dashboard authentication..."
read -p "Enter dashboard username [admin]: " DASHBOARD_USER
DASHBOARD_USER=${DASHBOARD_USER:-admin}

read -s -p "Enter dashboard password: " DASHBOARD_PASS
echo

# Generate htpasswd hash
DASHBOARD_HASH=$(openssl passwd -apr1 "$DASHBOARD_PASS")

# Update .env file
if [ -f .env ]; then
    sed -i "s/^TRAEFIK_DASHBOARD_USER=.*/TRAEFIK_DASHBOARD_USER=$DASHBOARD_USER/" .env
    sed -i "s|^TRAEFIK_DASHBOARD_PASSWORD=.*|TRAEFIK_DASHBOARD_PASSWORD=$DASHBOARD_HASH|" .env
fi

echo ""
echo "✅ Traefik infrastructure setup complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Ensure DNS records point all subdomains to this server"
echo "2. Run: ./scripts/deploy.sh"
echo "3. SSL certificates will be generated automatically"
echo ""
echo "📊 Required DNS Records (A records):"
source .env
source config/domains.sh
echo "   $FRONTEND_DOMAIN"
echo "   $API_DOMAIN"
echo "   $CMS_DOMAIN"
echo "   $MINIO_DOMAIN"
echo "   $MINIO_CONSOLE_DOMAIN"
echo "   $DB_DOMAIN"
echo "   $SEARCH_DOMAIN"
echo "   $TRAEFIK_DOMAIN"