terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # Note: In production, configure an S3 backend for remote state:
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "eks-fargate/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-locks"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Environment = var.environment
      Project     = "EKS-Fargate"
    }
  }
}

locals {
  full_cluster_name = "${var.environment}-${var.cluster_name}"
}

# Module 1: VPC Networking
module "vpc" {
  source = "./modules/vpc"

  environment          = var.environment
  cluster_name         = local.full_cluster_name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  single_nat_gateway   = var.single_nat_gateway
}

# Module 2: EKS Control Plane
module "eks" {
  source = "./modules/eks"

  environment     = var.environment
  cluster_name    = local.full_cluster_name
  cluster_version = var.cluster_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids
}

# Module 3: EKS Fargate Profiles
module "fargate" {
  source = "./modules/fargate"

  environment        = var.environment
  cluster_name       = module.eks.cluster_name
  private_subnet_ids = module.vpc.private_subnet_ids
  fargate_profiles   = var.fargate_profiles
}
