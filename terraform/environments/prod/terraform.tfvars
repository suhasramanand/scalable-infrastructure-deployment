# Production Environment Configuration

aws_region = "us-west-2"
environment = "prod"
project_name = "scalable-infra"

kubernetes_version = "1.28"

node_instance_types = ["t3.large", "t3.xlarge"]
min_nodes = 3
max_nodes = 20
desired_nodes = 5

db_instance_class = "db.t3.small"
db_allocated_storage = 100
db_name = "scalableapp_prod"
db_username = "admin"
db_password = "prod-secure-password"  # In production, use AWS Secrets Manager
