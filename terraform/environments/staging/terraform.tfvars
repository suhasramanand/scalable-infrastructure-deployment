# Staging Environment Configuration

aws_region = "us-west-2"
environment = "staging"
project_name = "scalable-infra"

kubernetes_version = "1.28"

node_instance_types = ["t3.medium"]
min_nodes = 2
max_nodes = 10
desired_nodes = 3

db_instance_class = "db.t3.micro"
db_allocated_storage = 50
db_name = "scalableapp_staging"
db_username = "admin"
db_password = "staging-password-123"  # In production, use AWS Secrets Manager
