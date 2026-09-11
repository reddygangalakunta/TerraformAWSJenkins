aws_region           = "us-east-1"
environment          = "dev"
cluster_name         = "eks-fargate-cluster"
cluster_version      = "1.30"
vpc_cidr             = "10.10.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
private_subnet_cidrs = ["10.10.10.0/24", "10.10.20.0/24"]
single_nat_gateway   = true

fargate_profiles = {
  kube-system = {
    namespace = "kube-system"
  }
  default = {
    namespace = "default"
  }
  dev-app = {
    namespace = "dev-app"
  }
}
