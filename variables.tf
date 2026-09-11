variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "cluster_name" {
  description = "Base name for the EKS Cluster"
  type        = string
  default     = "eks-fargate-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.30"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of Availability Zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "single_nat_gateway" {
  description = "Use single NAT gateway (true for cost savings, false for high availability per AZ)"
  type        = bool
  default     = true
}

variable "fargate_profiles" {
  description = "Map of Fargate profiles to provision"
  type = map(object({
    namespace = string
    labels    = optional(map(string))
  }))
  default = {
    kube-system = {
      namespace = "kube-system"
    }
    default = {
      namespace = "default"
    }
    app = {
      namespace = "app"
    }
  }
}
