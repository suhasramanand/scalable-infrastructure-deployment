#!/bin/bash

# Simplified local testing script
set -e

echo "🚀 Starting simplified local testing..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Test Terraform configuration
test_terraform() {
    print_status "Testing Terraform configuration..."
    
    cd terraform
    
    # Initialize Terraform (without backend)
    if terraform init -backend=false > /dev/null 2>&1; then
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

# Test Dockerfile syntax
test_dockerfiles() {
    print_status "Testing Dockerfile syntax..."
    
    # Test frontend Dockerfile
    if docker build --no-cache -f microservices/frontend/Dockerfile microservices/frontend > /dev/null 2>&1; then
        print_status "Frontend Dockerfile build successful ✓"
    else
        print_error "Frontend Dockerfile build failed ✗"
        return 1
    fi
    
    # Test backend Dockerfile
    if docker build --no-cache -f microservices/backend/Dockerfile microservices/backend > /dev/null 2>&1; then
        print_status "Backend Dockerfile build successful ✓"
    else
        print_error "Backend Dockerfile build failed ✗"
        return 1
    fi
    
    # Test API Gateway Dockerfile
    if docker build --no-cache -f microservices/api-gateway/Dockerfile microservices/api-gateway > /dev/null 2>&1; then
        print_status "API Gateway Dockerfile build successful ✓"
    else
        print_error "API Gateway Dockerfile build failed ✗"
        return 1
    fi
}

# Main test execution
main() {
    echo "🧪 Running simplified local tests..."
    echo "=================================="
    
    test_terraform
    test_kubernetes_manifests
    test_github_workflows
    test_dockerfiles
    
    echo "=================================="
    print_status "🎉 All tests passed successfully!"
    print_status "Ready for deployment to production"
}

# Run main function
main "$@"
