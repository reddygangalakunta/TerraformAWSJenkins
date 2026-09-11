output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of Public Subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of Private Subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "eks_cluster_name" {
  description = "Name of the EKS Cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint URL of the EKS Cluster"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_certificate_authority" {
  description = "Certificate Authority data for the EKS Cluster"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "fargate_pod_execution_role_arn" {
  description = "IAM Role ARN for Fargate Pod Execution"
  value       = module.fargate.fargate_pod_execution_role_arn
}

output "fargate_profiles" {
  description = "Details of provisioned Fargate profiles"
  value       = module.fargate.fargate_profile_arns
}
