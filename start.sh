#!/bin/bash

# Quick Start Script for MyWebClass.org Docker Infrastructure
# This script helps you get started quickly

set -e

echo "🚀 MyWebClass.org Docker Setup"
echo "================================"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

echo "✅ Docker is running"
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp .env.example .env
    echo "⚠️  Please edit .env file with your Cloudflare credentials:"
    echo "   - CF_DNS_API_TOKEN"
    echo "   - CF_ZONE_API_TOKEN"
    echo "   - TRAEFIK_DASHBOARD_CREDENTIALS"
    echo ""
    echo "To generate dashboard credentials, run:"
    echo "docker run --rm httpd:2.4-alpine htpasswd -nbB admin \"YourPassword\" | sed -e s/\\$/\\$\\$/g"
    echo ""
    read -p "Press Enter after you've updated the .env file..."
else
    echo "✅ .env file exists"
fi

# Check if acme.json has correct permissions
if [ -f traefik/acme.json ]; then
    PERMS=$(stat -f "%OLp" traefik/acme.json 2>/dev/null || stat -c "%a" traefik/acme.json 2>/dev/null)
    if [ "$PERMS" != "600" ]; then
        echo "🔒 Setting correct permissions on acme.json..."
        chmod 600 traefik/acme.json
    fi
    echo "✅ acme.json permissions are correct"
else
    echo "⚠️  acme.json not found (will be created automatically)"
fi

echo ""
echo "🎯 Starting Docker containers..."
docker-compose up -d

echo ""
echo "⏳ Waiting for services to start..."
sleep 5

echo ""
echo "📊 Container Status:"
docker-compose ps

echo ""
echo "================================"
echo "✨ Setup Complete!"
echo ""
echo "Your services are now running:"
echo "  🌐 Main Site: https://mywebclass.org"
echo "  📊 Traefik Dashboard: https://traefik.mywebclass.org"
echo ""
echo "Useful commands:"
echo "  View logs:        docker-compose logs -f"
echo "  Stop services:    docker-compose down"
echo "  Restart:          docker-compose restart"
echo "  Update content:   Edit files in www/ directory"
echo ""
echo "Note: SSL certificates may take a few minutes to generate."
echo "Check logs with: docker-compose logs -f traefik"
echo "================================"
