# Scalable Infrastructure Deployment

A comprehensive, production-ready infrastructure deployment solution using Terraform, Kubernetes (AWS EKS), and CI/CD pipelines for scalable microservices architecture.

## 🏗️ Architecture Overview

This project provides a complete infrastructure-as-code solution for deploying scalable microservices on AWS using:

- **Terraform** for infrastructure provisioning
- **AWS EKS** for Kubernetes cluster management
- **GitHub Actions** for CI/CD automation
- **Microservices architecture** with React frontend, Node.js backend, and API Gateway
- **Monitoring and observability** with Prometheus, Grafana, and ELK stack

## 📁 Project Structure

```
scalable-infrastructure-deployment/
├── terraform/                    # Infrastructure as Code
│   ├── main.tf                   # Main Terraform configuration
│   ├── variables.tf              # Variable definitions
│   ├── outputs.tf                # Output definitions
│   ├── modules/                  # Reusable Terraform modules
│   │   ├── vpc/                  # VPC module
│   │   ├── eks/                  # EKS module
│   │   ├── rds/                  # RDS module
│   │   └── iam/                  # IAM module
│   └── environments/             # Environment-specific configurations
│       ├── dev/
│       ├── staging/
│       └── prod/
├── kubernetes/                   # Kubernetes manifests
│   ├── namespaces.yaml           # Namespace definitions
│   ├── manifests/                # Application manifests
│   │   ├── frontend-deployment.yaml
│   │   ├── backend-deployment.yaml
│   │   ├── api-gateway-deployment.yaml
│   │   ├── redis-deployment.yaml
│   │   ├── ingress.yaml
│   │   ├── hpa.yaml
│   │   ├── network-policies.yaml
│   │   └── secrets.yaml
│   └── helm-charts/              # Helm charts
│       └── scalable-app/
├── microservices/                # Application code
│   ├── frontend/                 # React frontend
│   ├── backend/                  # Node.js backend
│   └── api-gateway/              # API Gateway service
├── .github/workflows/            # CI/CD pipelines
│   ├── terraform-plan.yml
│   ├── terraform-apply.yml
│   ├── docker-build.yml
│   ├── k8s-deploy.yml
│   └── monitoring.yml
└── docs/                         # Documentation
```

## 🚀 Quick Start

### Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- kubectl
- Helm
- Docker
- Node.js (for local development)

### 1. Infrastructure Deployment

```bash
# Navigate to terraform directory
cd terraform

# Initialize Terraform
terraform init

# Plan infrastructure changes
terraform plan -var-file="environments/dev/terraform.tfvars"

# Apply infrastructure
terraform apply -var-file="environments/dev/terraform.tfvars"
```

### 2. Kubernetes Deployment

```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-west-2 --name scalable-infra-dev

# Deploy Kubernetes manifests
kubectl apply -f kubernetes/namespaces.yaml
kubectl apply -f kubernetes/manifests/

# Verify deployment
kubectl get pods -n scalable-app
```

### 3. Using Helm Charts

```bash
# Install the application using Helm
helm install scalable-app kubernetes/helm-charts/scalable-app \
  --namespace scalable-app \
  --create-namespace
```

## 🔧 Configuration

### Environment Variables

The application supports multiple environments (dev, staging, prod) with environment-specific configurations:

- **AWS Region**: Configured per environment
- **Database**: PostgreSQL with connection pooling
- **Cache**: Redis for session management and caching
- **Scaling**: Auto-scaling based on CPU and memory metrics

### Secrets Management

Sensitive data is managed through Kubernetes secrets:

```bash
# Create database credentials secret
kubectl create secret generic database-credentials \
  --from-literal=host=your-db-host \
  --from-literal=username=your-username \
  --from-literal=password=your-password \
  --namespace scalable-app
```

## 📊 Monitoring and Observability

The infrastructure includes comprehensive monitoring:

- **Prometheus** for metrics collection
- **Grafana** for visualization
- **Jaeger** for distributed tracing
- **ELK Stack** for log aggregation
- **Health checks** and readiness probes

### Accessing Monitoring Dashboards

```bash
# Port forward to access Grafana
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring

# Access Grafana at http://localhost:3000
# Default credentials: admin / (check secrets)
```

## 🔄 CI/CD Pipeline

The GitHub Actions workflows provide:

1. **Infrastructure Validation**: Terraform plan and validation
2. **Application Building**: Docker image builds with security scanning
3. **Deployment**: Automated Kubernetes deployments
4. **Monitoring Setup**: Observability stack deployment
5. **Security**: Vulnerability scanning with Trivy

### Pipeline Triggers

- **Pull Requests**: Terraform plan and application builds
- **Main Branch**: Full deployment to production
- **Manual**: Environment-specific deployments

## 🛡️ Security Features

- **Network Policies**: Pod-to-pod communication restrictions
- **Security Groups**: VPC-level network isolation
- **IAM Roles**: Least privilege access patterns
- **Secrets Management**: Encrypted secrets storage
- **Container Security**: Non-root user containers
- **Rate Limiting**: API request throttling

## 📈 Scaling and Performance

### Horizontal Pod Autoscaling

```yaml
# Example HPA configuration
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
spec:
  minReplicas: 3
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        averageUtilization: 70
```

### Cluster Autoscaling

The EKS cluster automatically scales nodes based on demand:

- **Minimum Nodes**: 1 (dev), 2 (staging), 3 (prod)
- **Maximum Nodes**: 5 (dev), 10 (staging), 20 (prod)
- **Instance Types**: t3.medium, t3.large, t3.xlarge

## 🔍 Troubleshooting

### Common Issues

1. **Terraform State Lock**: Check S3 backend configuration
2. **Kubernetes Resources**: Verify resource limits and requests
3. **Database Connections**: Check security groups and credentials
4. **Image Pull Errors**: Verify container registry access

### Debug Commands

```bash
# Check pod logs
kubectl logs -f deployment/backend-service -n scalable-app

# Describe resources
kubectl describe pod <pod-name> -n scalable-app

# Check events
kubectl get events -n scalable-app --sort-by=.metadata.creationTimestamp
```

## 📚 Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and validation
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **suhasramanand** - *Initial work* - [GitHub](https://github.com/suhasramanand)

## 🙏 Acknowledgments

- AWS for providing the cloud infrastructure
- Kubernetes community for the orchestration platform
- Terraform for infrastructure as code capabilities
- All open-source contributors who made this possible
