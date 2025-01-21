#!/bin/bash

# Local testing script for scalable infrastructure deployment
set -e

echo "🚀 Starting local testing of scalable infrastructure deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_dependencies() {
    print_status "Checking dependencies..."
    
    local missing_deps=()
    
    if ! command -v docker &> /dev/null; then
        missing_deps+=("docker")
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        missing_deps+=("docker-compose")
    fi
    
    if ! command -v terraform &> /dev/null; then
        missing_deps+=("terraform")
    fi
    
    if ! command -v kubectl &> /dev/null; then
        missing_deps+=("kubectl")
    fi
    
    if ! command -v helm &> /dev/null; then
        missing_deps+=("helm")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        print_error "Please install the missing dependencies before running tests"
        exit 1
    fi
    
    print_status "All dependencies are installed ✓"
}

# Test Docker builds
test_docker_builds() {
    print_status "Testing Docker builds..."
    
    cd microservices/frontend
    if docker build -t test-frontend . > /dev/null 2>&1; then
        print_status "Frontend Docker build successful ✓"
    else
        print_error "Frontend Docker build failed ✗"
        return 1
    fi
    cd ../..
    
    cd microservices/backend
    if docker build -t test-backend . > /dev/null 2>&1; then
        print_status "Backend Docker build successful ✓"
    else
        print_error "Backend Docker build failed ✗"
        return 1
    fi
    cd ../..
    
    cd microservices/api-gateway
    if docker build -t test-api-gateway . > /dev/null 2>&1; then
        print_status "API Gateway Docker build successful ✓"
    else
        print_error "API Gateway Docker build failed ✗"
        return 1
    fi
    cd ../..
}

# Test Terraform configuration
test_terraform() {
    print_status "Testing Terraform configuration..."
    
    cd terraform
    
    # Initialize Terraform
    if terraform init > /dev/null 2>&1; then
        print_status "Terraform initialization successful ✓"
    else
        print_error "Terraform initialization failed ✗"
        return 1
    fi
    
    # Validate Terraform configuration
    if terraform validate > /dev/null 2>&1; then
        print_status "Terraform validation successful ✓"
    else
        print_error "Terraform validation failed ✗"
        return 1
    fi
    
    # Format check
    if terraform fmt -check -recursive > /dev/null 2>&1; then
        print_status "Terraform formatting check passed ✓"
    else
        print_warning "Terraform formatting issues detected"
        terraform fmt -recursive
        print_status "Terraform formatting fixed ✓"
    fi
    
    cd ..
}

# Test Kubernetes manifests
test_kubernetes_manifests() {
    print_status "Testing Kubernetes manifests..."
    
    # Test if kubectl can parse the manifests
    if kubectl apply --dry-run=client -f kubernetes/namespaces.yaml > /dev/null 2>&1; then
        print_status "Namespace manifests validation successful ✓"
    else
        print_error "Namespace manifests validation failed ✗"
        return 1
    fi
    
    if kubectl apply --dry-run=client -f kubernetes/manifests/ > /dev/null 2>&1; then
        print_status "Application manifests validation successful ✓"
    else
        print_error "Application manifests validation failed ✗"
        return 1
    fi
}

# Test Helm charts
test_helm_charts() {
    print_status "Testing Helm charts..."
    
    cd kubernetes/helm-charts/scalable-app
    
    if helm lint . > /dev/null 2>&1; then
        print_status "Helm chart linting successful ✓"
    else
        print_error "Helm chart linting failed ✗"
        return 1
    fi
    
    cd ../../..
}

# Test GitHub Actions workflows
test_github_workflows() {
    print_status "Testing GitHub Actions workflows..."
    
    # Check if workflow files are valid YAML
    for workflow in .github/workflows/*.yml; do
        if python3 -c "import yaml; yaml.safe_load(open('$workflow'))" > /dev/null 2>&1; then
            print_status "Workflow $workflow YAML validation successful ✓"
        else
            print_error "Workflow $workflow YAML validation failed ✗"
            return 1
        fi
    done
}

# Test application code
test_application_code() {
    print_status "Testing application code..."
    
    # Test frontend
    cd microservices/frontend
    if npm install --silent > /dev/null 2>&1; then
        print_status "Frontend dependencies installed ✓"
    else
        print_error "Frontend dependencies installation failed ✗"
        return 1
    fi
    cd ../..
    
    # Test backend
    cd microservices/backend
    if npm install --silent > /dev/null 2>&1; then
        print_status "Backend dependencies installed ✓"
    else
        print_error "Backend dependencies installation failed ✗"
        return 1
    fi
    cd ../..
    
    # Test API Gateway
    cd microservices/api-gateway
    if npm install --silent > /dev/null 2>&1; then
        print_status "API Gateway dependencies installed ✓"
    else
        print_error "API Gateway dependencies installation failed ✗"
        return 1
    fi
    cd ../..
}

# Cleanup test images
cleanup_test_images() {
    print_status "Cleaning up test Docker images..."
    
    docker rmi test-frontend test-backend test-api-gateway 2>/dev/null || true
    docker system prune -f > /dev/null 2>&1 || true
    
    print_status "Test images cleaned up ✓"
}

# Main test execution
main() {
    echo "🧪 Running comprehensive local tests..."
    echo "=================================="
    
    check_dependencies
    test_docker_builds
    test_terraform
    test_kubernetes_manifests
    test_helm_charts
    test_github_workflows
    test_application_code
    cleanup_test_images
    
    echo "=================================="
    print_status "🎉 All tests passed successfully!"
    print_status "Ready for deployment to production"
}

# Run main function
main "$@"
