# IAM Module Outputs

output "eks_admin_role_arn" {
  description = "ARN of the EKS admin role"
  value       = aws_iam_role.eks_admin.arn
}

output "eks_admin_role_name" {
  description = "Name of the EKS admin role"
  value       = aws_iam_role.eks_admin.name
}

output "eks_service_role_arn" {
  description = "ARN of the EKS service role"
  value       = aws_iam_role.eks_service.arn
}

output "eks_service_role_name" {
  description = "Name of the EKS service role"
  value       = aws_iam_role.eks_service.name
}

output "eks_node_group_role_arn" {
  description = "ARN of the EKS node group role"
  value       = aws_iam_role.eks_node_group.arn
}

output "eks_node_group_role_name" {
  description = "Name of the EKS node group role"
  value       = aws_iam_role.eks_node_group.name
}
