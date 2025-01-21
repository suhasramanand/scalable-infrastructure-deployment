#!/bin/bash

# Cleanup script to remove test files before publishing
set -e

echo "🧹 Cleaning up test files before publishing..."

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

# Remove test Docker images
cleanup_docker_images() {
    print_status "Cleaning up test Docker images..."
    
    # Remove test images
    docker rmi test-frontend test-backend test-api-gateway 2>/dev/null || true
    
    # Remove dangling images
    docker image prune -f > /dev/null 2>&1 || true
    
    # Remove unused containers
    docker container prune -f > /dev/null 2>&1 || true
    
    # Remove unused networks
    docker network prune -f > /dev/null 2>&1 || true
    
    # Remove unused volumes
    docker volume prune -f > /dev/null 2>&1 || true
    
    print_status "Docker cleanup completed ✓"
}

# Remove test Terraform files
cleanup_terraform_files() {
    print_status "Cleaning up Terraform test files..."
    
    cd terraform
    
    # Remove .terraform directory
    rm -rf .terraform/ 2>/dev/null || true
    
    # Remove terraform.tfstate files
    rm -f terraform.tfstate* 2>/dev/null || true
    
    # Remove .terraform.lock.hcl
    rm -f .terraform.lock.hcl 2>/dev/null || true
    
    # Remove tfplan files
    rm -f *.tfplan 2>/dev/null || true
    
    cd ..
    
    print_status "Terraform cleanup completed ✓"
}

# Remove test Kubernetes files
cleanup_kubernetes_files() {
    print_status "Cleaning up Kubernetes test files..."
    
    # Remove any test manifests
    find kubernetes/ -name "*.test.yaml" -delete 2>/dev/null || true
    find kubernetes/ -name "*.test.yml" -delete 2>/dev/null || true
    
    print_status "Kubernetes cleanup completed ✓"
}

# Remove test application files
cleanup_application_files() {
    print_status "Cleaning up application test files..."
    
    # Remove node_modules directories
    find microservices/ -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true
    
    # Remove package-lock.json files
    find microservices/ -name "package-lock.json" -delete 2>/dev/null || true
    
    # Remove build directories
    find microservices/ -name "build" -type d -exec rm -rf {} + 2>/dev/null || true
    find microservices/ -name "dist" -type d -exec rm -rf {} + 2>/dev/null || true
    
    # Remove TypeScript build files
    find microservices/ -name "*.js" -not -name "healthcheck.js" -delete 2>/dev/null || true
    find microservices/ -name "*.js.map" -delete 2>/dev/null || true
    
    # Remove test files
    find microservices/ -name "*.test.js" -delete 2>/dev/null || true
    find microservices/ -name "*.test.ts" -delete 2>/dev/null || true
    find microservices/ -name "*.spec.js" -delete 2>/dev/null || true
    find microservices/ -name "*.spec.ts" -delete 2>/dev/null || true
    
    print_status "Application cleanup completed ✓"
}

# Remove temporary files
cleanup_temp_files() {
    print_status "Cleaning up temporary files..."
    
    # Remove .DS_Store files
    find . -name ".DS_Store" -delete 2>/dev/null || true
    
    # Remove editor temporary files
    find . -name "*.swp" -delete 2>/dev/null || true
    find . -name "*.swo" -delete 2>/dev/null || true
    find . -name "*~" -delete 2>/dev/null || true
    
    # Remove log files
    find . -name "*.log" -delete 2>/dev/null || true
    
    # Remove coverage directories
    find . -name "coverage" -type d -exec rm -rf {} + 2>/dev/null || true
    
    print_status "Temporary files cleanup completed ✓"
}

# Remove test scripts
cleanup_test_scripts() {
    print_status "Removing test scripts..."
    
    rm -f scripts/test-local.sh 2>/dev/null || true
    rm -f scripts/cleanup-test-files.sh 2>/dev/null || true
    
    print_status "Test scripts removed ✓"
}

# Main cleanup execution
main() {
    echo "🧹 Starting cleanup process..."
    echo "============================="
    
    cleanup_docker_images
    cleanup_terraform_files
    cleanup_kubernetes_files
    cleanup_application_files
    cleanup_temp_files
    cleanup_test_scripts
    
    echo "============================="
    print_status "🎉 Cleanup completed successfully!"
    print_status "Repository is ready for publishing"
}

# Run main function
main "$@"
