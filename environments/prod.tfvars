aws_region           = "us-east-1"
environment          = "prod"
cluster_name         = "eks-fargate-cluster"
cluster_version      = "1.30"
vpc_cidr             = "10.30.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
public_subnet_cidrs  = ["10.30.1.0/24", "10.30.2.0/24", "10.30.3.0/24"]
private_subnet_cidrs = ["10.30.10.0/24", "10.30.20.0/24", "10.30.30.0/24"]
single_nat_gateway   = false # Highly available NAT Gateway per AZ in prod

fargate_profiles = {
  kube-system = {
    namespace = "kube-system"
  }
  default = {
    namespace = "default"
  }
  prod-app = {
    namespace = "prod-app"
  }
}
