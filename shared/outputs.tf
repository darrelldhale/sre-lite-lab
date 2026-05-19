output "ecr_repository_url" {
  description = "ECR repository URL — use this in terraform.tfvars for container_image"
  value       = aws_ecr_repository.ecr_repo.repository_url
}

output "vpc_flow_log_group_name" {
  description = "Name of the VPC flow logs CloudWatch log group"
  value       = aws_cloudwatch_log_group.vpc_flow_logs.name
}
