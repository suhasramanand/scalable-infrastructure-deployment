#!/bin/bash

# Final local testing script before publishing
set -e

echo "🚀 Starting final local testing before publishing..."

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

# Test Kubernetes manifests YAML syntax
test_kubernetes_yaml() {
    print_status "Testing Kubernetes manifests YAML syntax..."
    
    # Test namespaces
    if python3 -c "import yaml; yaml.safe_load_all(open('kubernetes/namespaces.yaml'))" > /dev/null 2>&1; then
        print_status "Namespace YAML syntax valid ✓"
    else
        print_error "Namespace YAML syntax invalid ✗"
        return 1
    fi
    
    # Test all manifest files
    for manifest in kubernetes/manifests/*.yaml; do
        if python3 -c "import yaml; yaml.safe_load_all(open('$manifest'))" > /dev/null 2>&1; then
            print_status "Manifest $(basename $manifest) YAML syntax valid ✓"
        else
            print_error "Manifest $(basename $manifest) YAML syntax invalid ✗"
            return 1
        fi
    done
}

# Test GitHub Actions workflows
test_github_workflows() {
    print_status "Testing GitHub Actions workflows..."
    
    # Check if workflow files are valid YAML
    for workflow in .github/workflows/*.yml; do
        if python3 -c "import yaml; yaml.safe_load(open('$workflow'))" > /dev/null 2>&1; then
            print_status "Workflow $(basename $workflow) YAML validation successful ✓"
        else
            print_error "Workflow $(basename $workflow) YAML validation failed ✗"
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

# Test file structure
test_file_structure() {
    print_status "Testing file structure..."
    
    # Check required directories exist
    required_dirs=("terraform" "kubernetes" "microservices" ".github" "scripts")
    for dir in "${required_dirs[@]}"; do
        if [ -d "$dir" ]; then
            print_status "Directory $dir exists ✓"
        else
            print_error "Directory $dir missing ✗"
            return 1
        fi
    done
    
    # Check required files exist
    required_files=("terraform/main.tf" "terraform/variables.tf" "kubernetes/namespaces.yaml")
    for file in "${required_files[@]}"; do
        if [ -f "$file" ]; then
            print_status "File $file exists ✓"
        else
            print_error "File $file missing ✗"
            return 1
        fi
    done
}

# Main test execution
main() {
    echo "🧪 Running final local tests..."
    echo "=================================="
    
    test_file_structure
    test_terraform
    test_kubernetes_yaml
    test_github_workflows
    test_dockerfiles
    
    echo "=================================="
    print_status "🎉 All tests passed successfully!"
    print_status "Ready for publishing to repository"
}

# Run main function
main "$@"
