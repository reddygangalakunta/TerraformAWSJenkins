output "fargate_pod_execution_role_arn" {
  description = "IAM Role ARN for Fargate Pod Execution"
  value       = aws_iam_role.fargate_pod_execution.arn
}

output "fargate_profile_arns" {
  description = "Map of created Fargate Profile ARNs"
  value       = { for k, v in aws_eks_fargate_profile.this : k => v.arn }
}

output "fargate_profile_ids" {
  description = "Map of created Fargate Profile IDs"
  value       = { for k, v in aws_eks_fargate_profile.this : k => v.id }
}
