# Development Environment Configuration

aws_region = "us-west-2"
environment = "dev"
project_name = "scalable-infra"

kubernetes_version = "1.28"

node_instance_types = ["t3.medium"]
min_nodes = 1
max_nodes = 5
desired_nodes = 2

db_instance_class = "db.t3.micro"
db_allocated_storage = 20
db_name = "scalableapp_dev"
db_username = "admin"
db_password = "dev-password-123"  # In production, use AWS Secrets Manager
