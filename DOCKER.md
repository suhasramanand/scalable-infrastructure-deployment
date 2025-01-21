# Docker Setup Guide

This project now includes a simplified Docker Compose setup that runs all services together locally.

## Quick Start

### Prerequisites
- Docker
- Docker Compose

### Start All Services

```bash
# Clone the repository
git clone https://github.com/suhasramanand/scalable-infrastructure-deployment.git
cd scalable-infrastructure-deployment

# Start all services
./start.sh
```

Or manually:

```bash
# Build and start all services
docker-compose up --build -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

## Services

| Service | Port | Description |
|---------|------|-------------|
| Frontend | 80 | React application with Nginx |
| API Gateway | 8080 | Node.js API gateway with rate limiting |
| Backend | 3000 | Node.js backend with PostgreSQL |
| PostgreSQL | 5432 | Database for application data |
| Redis | 6379 | Cache and session storage |
| Prometheus | 9090 | Metrics collection |
| Grafana | 3001 | Monitoring dashboard (admin/admin123) |

## Access Points

- **Frontend**: http://localhost
- **API Gateway**: http://localhost:8080
- **Backend API**: http://localhost:3000
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3001
- **PostgreSQL**: localhost:5432
- **Redis**: localhost:6379

## Development

### Viewing Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f api-gateway
```

### Restarting Services
```bash
# Restart all services
docker-compose restart

# Restart specific service
docker-compose restart backend
```

### Rebuilding Services
```bash
# Rebuild and restart all services
docker-compose up --build -d

# Rebuild specific service
docker-compose up --build -d backend
```

### Database Access
```bash
# Connect to PostgreSQL
docker-compose exec postgres psql -U admin -d scalableapp

# Connect to Redis
docker-compose exec redis redis-cli -a password123
```

### Monitoring

#### Prometheus Metrics
- Access: http://localhost:9090
- Query examples:
  - `up` - Service availability
  - `http_requests_total` - HTTP request metrics
  - `nodejs_heap_size_total` - Node.js memory usage

#### Grafana Dashboards
- Access: http://localhost:3001
- Username: `admin`
- Password: `admin123`
- Default dashboards for Node.js and system metrics

## Environment Variables

Key environment variables used in docker-compose.yml:

```yaml
# Database
POSTGRES_DB: scalableapp
POSTGRES_USER: admin
POSTGRES_PASSWORD: password123

# Redis
REDIS_PASSWORD: password123

# Backend
DB_HOST: postgres
DB_PORT: 5432
DB_NAME: scalableapp
DB_USER: admin
DB_PASSWORD: password123
REDIS_URL: redis://:password123@redis:6379

# API Gateway
BACKEND_SERVICE_URL: http://backend:3000
REDIS_URL: redis://:password123@redis:6379

# Frontend
REACT_APP_API_URL: http://localhost:8080
```

## Troubleshooting

### Common Issues

1. **Port conflicts**: Make sure ports 80, 3000, 5432, 6379, 8080, 9090, 3001 are available
2. **Permission issues**: On Linux/Mac, you might need `sudo` for Docker commands
3. **Service not starting**: Check logs with `docker-compose logs [service-name]`

### Reset Everything
```bash
# Stop and remove all containers, networks, and volumes
docker-compose down --volumes --remove-orphans

# Remove all images (optional)
docker-compose down --rmi all

# Start fresh
docker-compose up --build -d
```

### Health Checks
All services include health checks. Check status:
```bash
docker-compose ps
```

Services should show "healthy" status when ready.

## Production Considerations

This Docker Compose setup is designed for local development. For production:

1. Use environment-specific configuration files
2. Implement proper secrets management
3. Use external databases (AWS RDS, etc.)
4. Configure proper networking and security
5. Use container orchestration (Kubernetes) for scaling

## CI/CD Integration

The GitHub Actions workflow automatically tests the Docker Compose setup:

- Builds all services
- Starts the complete stack
- Runs health checks
- Performs integration tests
- Pushes images to registry (on main branch)

See `.github/workflows/docker-compose-build.yml` for details.
