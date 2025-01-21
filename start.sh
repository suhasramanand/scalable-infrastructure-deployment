#!/bin/bash

# Scalable Infrastructure Deployment - Local Development Setup
set -e

echo "🚀 Starting Scalable Infrastructure Deployment..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if Docker and Docker Compose are installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

print_status "Docker and Docker Compose are available ✓"

# Stop any existing containers
print_info "Stopping any existing containers..."
docker compose down --remove-orphans 2>/dev/null || true

# Build and start all services
print_status "Building and starting all services..."
docker compose up --build -d

# Wait for services to be healthy
print_info "Waiting for services to be healthy..."
sleep 30

# Check service health
print_status "Checking service health..."

services=("postgres" "redis" "backend" "api-gateway" "frontend" "prometheus" "grafana")

for service in "${services[@]}"; do
    if docker compose ps "$service" | grep -q "Up"; then
        print_status "$service is running ✓"
    else
        print_warning "$service is not running ✗"
    fi
done

echo ""
echo "🎉 Scalable Infrastructure Deployment is ready!"
echo ""
echo "📊 Access your services:"
echo "  🌐 Frontend:        http://localhost"
echo "  🔗 API Gateway:     http://localhost:8080"
echo "  🗄️  Backend:         http://localhost:3000"
echo "  📈 Prometheus:      http://localhost:9090"
echo "  📊 Grafana:         http://localhost:3001 (admin/admin123)"
echo "  🐘 PostgreSQL:      localhost:5432"
echo "  🔴 Redis:           localhost:6379"
echo ""
echo "📋 Useful commands:"
echo "  docker compose logs -f [service]  # View logs"
echo "  docker compose ps                 # Check status"
echo "  docker compose down               # Stop all services"
echo "  docker compose restart [service]  # Restart a service"
echo ""
