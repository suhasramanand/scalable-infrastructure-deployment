# Scalable Infrastructure Deployment

A microservices application with React frontend, Node.js backend, API Gateway, and infrastructure automation using Docker, Kubernetes, and Terraform.

## Architecture

This project contains:
- **React Frontend** - Modern React application with Material-UI components
- **Node.js Backend** - Express.js API with TypeScript, PostgreSQL, and Redis
- **API Gateway** - Express.js service with authentication and rate limiting
- **Docker** - Multi-stage builds for all services
- **Kubernetes** - Deployment manifests and Helm charts
- **Terraform** - AWS infrastructure provisioning
- **CI/CD** - GitHub Actions workflow for automated deployment

## Project Structure

```
scalable-infrastructure-deployment/
├── microservices/                # Application code
│   ├── frontend/                 # React frontend with Material-UI
│   │   ├── src/
│   │   │   ├── App.js           # Main application component
│   │   │   ├── components/      # React components (Dashboard, UserManagement, Analytics)
│   │   │   └── hooks/           # Custom hooks (useApi)
│   │   ├── package.json
│   │   └── Dockerfile
│   ├── backend/                  # Node.js backend with TypeScript
│   │   ├── src/
│   │   │   ├── routes/          # API routes (auth, users, dashboard)
│   │   │   ├── middleware/      # Express middleware
│   │   │   ├── config/          # Database and Redis configuration
│   │   │   └── utils/           # Logging utilities
│   │   ├── package.json
│   │   └── Dockerfile
│   └── api-gateway/              # API Gateway service
│       ├── src/
│       │   ├── middleware/      # Authentication and rate limiting
│       │   ├── config/          # Redis configuration
│       │   └── utils/           # Logging utilities
│       ├── package.json
│       └── Dockerfile
├── kubernetes/                   # Kubernetes manifests
│   ├── manifests/               # Deployment YAML files
│   │   ├── frontend-deployment.yaml
│   │   ├── backend-deployment.yaml
│   │   ├── api-gateway-deployment.yaml
│   │   ├── redis-deployment.yaml
│   │   ├── ingress.yaml
│   │   ├── hpa.yaml
│   │   ├── network-policies.yaml
│   │   └── secrets.yaml
│   ├── helm-charts/             # Helm chart for the application
│   │   └── scalable-app/
│   └── namespaces.yaml
├── terraform/                    # Infrastructure as Code
│   ├── main.tf                  # Main Terraform configuration
│   ├── variables.tf             # Variable definitions
│   ├── outputs.tf               # Output definitions
│   ├── modules/                 # Terraform modules
│   │   ├── vpc/                 # VPC configuration
│   │   ├── eks/                 # EKS cluster
│   │   ├── rds/                 # PostgreSQL database
│   │   └── iam/                 # IAM roles and policies
│   └── environments/            # Environment-specific variables
│       ├── dev/
│       ├── staging/
│       └── prod/
├── .github/workflows/           # CI/CD pipeline
│   └── deploy.yml              # Single comprehensive deployment workflow
├── docker-compose.yml          # Local development setup
├── monitoring/                 # Monitoring configuration
│   └── prometheus.yml
└── scripts/                    # Utility scripts
```

## Quick Start

### Prerequisites

- Docker and Docker Compose
- Node.js 18+
- AWS CLI (for infrastructure deployment)
- Terraform (for infrastructure deployment)
- kubectl (for Kubernetes deployment)

### Local Development

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd scalable-infrastructure-deployment
   ```

2. **Start all services locally**
   ```bash
   docker-compose up --build
   ```

3. **Access the application**
   - Frontend: http://localhost:80
   - API Gateway: http://localhost:8080
   - Backend: http://localhost:3000
   - Prometheus: http://localhost:9090
   - Grafana: http://localhost:3001

### Building Individual Services

```bash
# Build backend service
cd microservices/backend
npm install
npm run build
npm start

# Build API Gateway
cd microservices/api-gateway
npm install
npm run build
npm start

# Build frontend
cd microservices/frontend
npm install
npm run build
npm start
```

## Infrastructure Deployment

### Using Terraform

1. **Configure AWS credentials**
   ```bash
   aws configure
   ```

2. **Deploy infrastructure**
   ```bash
   cd terraform
   terraform init
   terraform plan -var-file="environments/dev/terraform.tfvars"
   terraform apply -var-file="environments/dev/terraform.tfvars"
   ```

### Using Kubernetes

1. **Deploy to Kubernetes**
   ```bash
   kubectl apply -f kubernetes/namespaces.yaml
   kubectl apply -f kubernetes/manifests/
   ```

2. **Using Helm**
   ```bash
   helm install scalable-app kubernetes/helm-charts/scalable-app \
     --namespace scalable-app \
     --create-namespace
   ```

## CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/deploy.yml`) provides:

1. **Build and Test** - Linting, building, and testing all services
2. **Security Scan** - Vulnerability scanning with Trivy
3. **Docker Build** - Building and pushing Docker images
4. **Infrastructure** - Terraform deployment
5. **Application Deployment** - Kubernetes deployment with Helm

## Services

### Frontend
- **Technology**: React 18 with Material-UI
- **Features**: Dashboard, User Management, Analytics
- **Port**: 80 (nginx)

### Backend
- **Technology**: Node.js with Express and TypeScript
- **Features**: User authentication, CRUD operations, PostgreSQL integration
- **Port**: 3000

### API Gateway
- **Technology**: Node.js with Express and TypeScript
- **Features**: Request routing, authentication, rate limiting, Redis caching
- **Port**: 8080

### Database
- **PostgreSQL**: Primary database
- **Redis**: Caching and session storage

## Monitoring

- **Prometheus**: Metrics collection
- **Grafana**: Visualization dashboards
- **Health Checks**: Built-in health endpoints for all services

## Technologies Used

- **Frontend**: React, Material-UI, React Router, React Query
- **Backend**: Node.js, Express, TypeScript, PostgreSQL, Redis
- **Infrastructure**: Docker, Kubernetes, Terraform, AWS
- **CI/CD**: GitHub Actions
- **Monitoring**: Prometheus, Grafana
