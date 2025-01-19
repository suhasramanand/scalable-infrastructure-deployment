# Deployment Guide

This guide provides detailed instructions for deploying the scalable infrastructure on AWS.

## Prerequisites

### Required Tools

- AWS CLI v2
- Terraform >= 1.0
- kubectl >= 1.28
- Helm >= 3.13
- Docker (for building images)

### AWS Permissions

Ensure your AWS credentials have the following permissions:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:*",
                "ec2:*",
                "iam:*",
                "rds:*",
                "vpc:*",
                "s3:*",
                "route53:*",
                "acm:*"
            ],
            "Resource": "*"
        }
    ]
}
```

## Step-by-Step Deployment

### 1. Environment Setup

```bash
# Clone the repository
git clone https://github.com/suhasramanand/scalable-infrastructure-deployment.git
cd scalable-infrastructure-deployment

# Configure AWS credentials
aws configure
```

### 2. Infrastructure Provisioning

#### Development Environment

```bash
cd terraform

# Initialize Terraform
terraform init

# Create S3 backend (first time only)
aws s3 mb s3://your-terraform-state-bucket
aws s3api put-bucket-versioning --bucket your-terraform-state-bucket --versioning-configuration Status=Enabled

# Configure backend in terraform.tfvars
echo 'bucket = "your-terraform-state-bucket"' >> terraform.tfvars

# Plan the infrastructure
terraform plan -var-file="environments/dev/terraform.tfvars"

# Apply the infrastructure
terraform apply -var-file="environments/dev/terraform.tfvars"
```

#### Production Environment

```bash
# For production, use the production configuration
terraform plan -var-file="environments/prod/terraform.tfvars"
terraform apply -var-file="environments/prod/terraform.tfvars"
```

### 3. Kubernetes Cluster Configuration

```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-west-2 --name scalable-infra-dev

# Verify cluster access
kubectl get nodes

# Create namespaces
kubectl apply -f kubernetes/namespaces.yaml
```

### 4. Database Setup

```bash
# Get database endpoint from Terraform output
terraform output rds_endpoint

# Create database secrets
kubectl create secret generic database-credentials \
  --from-literal=host=$(terraform output -raw rds_endpoint) \
  --from-literal=port=5432 \
  --from-literal=name=scalableapp_dev \
  --from-literal=username=admin \
  --from-literal=password=your-secure-password \
  --namespace scalable-app

# Create Redis secrets
kubectl create secret generic redis-credentials \
  --from-literal=password=your-redis-password \
  --from-literal=url=redis://redis-service:6379 \
  --namespace scalable-app
```

### 5. Application Deployment

#### Using Kubernetes Manifests

```bash
# Deploy all application components
kubectl apply -f kubernetes/manifests/

# Verify deployments
kubectl get pods -n scalable-app
kubectl get services -n scalable-app
kubectl get ingress -n scalable-app
```

#### Using Helm Charts

```bash
# Install using Helm
helm install scalable-app kubernetes/helm-charts/scalable-app \
  --namespace scalable-app \
  --create-namespace \
  --set image.tag=latest \
  --set database.host=$(terraform output -raw rds_endpoint)

# Upgrade existing deployment
helm upgrade scalable-app kubernetes/helm-charts/scalable-app \
  --namespace scalable-app \
  --set image.tag=new-version
```

### 6. Monitoring Setup

```bash
# Install Prometheus and Grafana
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install monitoring stack
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set grafana.adminPassword=your-admin-password

# Install Jaeger for tracing
kubectl apply -f monitoring/jaeger/

# Install ELK stack for logging
helm repo add elastic https://helm.elastic.co
helm install elasticsearch elastic/elasticsearch --namespace monitoring
helm install kibana elastic/kibana --namespace monitoring
helm install logstash elastic/logstash --namespace monitoring
```

### 7. SSL Certificate Setup

```bash
# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Create Let's Encrypt issuer
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF

# Update ingress to use SSL
kubectl patch ingress scalable-app-ingress -n scalable-app -p '
{
  "spec": {
    "tls": [
      {
        "hosts": ["app.scalable-app.com", "api.scalable-app.com"],
        "secretName": "scalable-app-tls"
      }
    ]
  }
}'
```

## Verification Steps

### 1. Check Infrastructure

```bash
# Verify EKS cluster
aws eks describe-cluster --name scalable-infra-dev

# Verify RDS instance
aws rds describe-db-instances --db-instance-identifier scalable-infra-dev-database

# Verify VPC and subnets
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=scalable-infra-dev"
```

### 2. Check Application Health

```bash
# Check pod status
kubectl get pods -n scalable-app

# Check service endpoints
kubectl get endpoints -n scalable-app

# Check ingress
kubectl describe ingress scalable-app-ingress -n scalable-app

# Test health endpoints
kubectl port-forward svc/backend-service 3000:80 -n scalable-app
curl http://localhost:3000/health
```

### 3. Check Monitoring

```bash
# Access Grafana
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring
# Open http://localhost:3000

# Access Prometheus
kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n monitoring
# Open http://localhost:9090

# Access Jaeger
kubectl port-forward svc/jaeger 16686:16686 -n monitoring
# Open http://localhost:16686
```

## Troubleshooting

### Common Issues

1. **Terraform State Lock**
   ```bash
   terraform force-unlock <lock-id>
   ```

2. **Pod Startup Issues**
   ```bash
   kubectl describe pod <pod-name> -n scalable-app
   kubectl logs <pod-name> -n scalable-app
   ```

3. **Database Connection Issues**
   ```bash
   # Check security groups
   aws ec2 describe-security-groups --group-ids <security-group-id>
   
   # Test database connectivity
   kubectl run test-pod --image=postgres:15 --rm -it -- psql -h <db-endpoint> -U admin
   ```

4. **Ingress Issues**
   ```bash
   # Check ingress controller
   kubectl get pods -n ingress-nginx
   
   # Check ingress status
   kubectl describe ingress scalable-app-ingress -n scalable-app
   ```

### Performance Optimization

1. **Resource Tuning**
   ```bash
   # Adjust HPA settings
   kubectl patch hpa backend-hpa -n scalable-app -p '{"spec":{"minReplicas":5}}'
   ```

2. **Database Optimization**
   ```bash
   # Scale RDS instance
   aws rds modify-db-instance --db-instance-identifier scalable-infra-dev-database --db-instance-class db.t3.small
   ```

## Rollback Procedures

### Application Rollback

```bash
# Rollback using kubectl
kubectl rollout undo deployment/backend-service -n scalable-app

# Rollback using Helm
helm rollback scalable-app 1 -n scalable-app
```

### Infrastructure Rollback

```bash
# Rollback Terraform changes
terraform plan -var-file="environments/dev/terraform.tfvars" -destroy
terraform apply -var-file="environments/dev/terraform.tfvars" -destroy
```

## Maintenance

### Regular Tasks

1. **Update Dependencies**
   ```bash
   # Update Terraform providers
   terraform init -upgrade
   
   # Update Helm charts
   helm repo update
   ```

2. **Security Updates**
   ```bash
   # Update container images
   docker pull scalable-app/backend:latest
   
   # Scan for vulnerabilities
   trivy image scalable-app/backend:latest
   ```

3. **Backup Procedures**
   ```bash
   # Backup Terraform state
   aws s3 cp s3://your-terraform-state-bucket/terraform.tfstate terraform.tfstate.backup
   
   # Backup database
   aws rds create-db-snapshot --db-instance-identifier scalable-infra-dev-database --db-snapshot-identifier backup-$(date +%Y%m%d)
   ```

## Support

For issues and questions:

1. Check the troubleshooting section above
2. Review application logs
3. Check AWS CloudWatch logs
4. Open an issue in the GitHub repository

## Next Steps

After successful deployment:

1. Configure custom domains
2. Set up monitoring alerts
3. Implement backup strategies
4. Plan disaster recovery procedures
5. Optimize performance based on metrics
