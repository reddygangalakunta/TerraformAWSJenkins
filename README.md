# AWS EKS Fargate Infrastructure with Jenkins CI/CD Automation

This repository contains production-ready Infrastructure as Code (IaC) written in Terraform to provision an **AWS EKS Cluster with Serverless Fargate Worker Nodes** along with dedicated networking (VPC, public/private subnets, Internet & NAT Gateways).

It also includes a parameterized `Jenkinsfile` for automated multi-environment (`dev`, `staging`, `prod`) deployments with manual approval gates.

---

## 📁 Repository Structure

```
.
├── Jenkinsfile                  # Parameterized Jenkins CI/CD pipeline
├── main.tf                      # Root Terraform entrypoint orchestrating modules
├── variables.tf                 # Root Terraform variables
├── outputs.tf                   # Root Terraform output definitions
├── environments/                # Environment-specific variable overrides
│   ├── dev.tfvars               # Development environment settings
│   ├── staging.tfvars           # Staging environment settings
│   └── prod.tfvars              # Production environment settings (multi-AZ NAT)
└── modules/                     # Decoupled Terraform reusable modules
    ├── vpc/                     # VPC, Subnets, Route Tables, IGW, EIP, NAT Gateway
    ├── eks/                     # EKS Control Plane, Cluster IAM Role, SG
    └── fargate/                 # Fargate Profiles & Pod Execution IAM Role
```

---

## 🚀 Infrastructure Components

1. **Networking (VPC Module)**:
   - VPC with DNS hostnames and DNS support enabled.
   - Public Subnets with `kubernetes.io/role/elb = 1` tagging.
   - Private Subnets with `kubernetes.io/role/internal-elb = 1` tagging for Fargate pods.
   - Single NAT Gateway for `dev` & `staging` (cost optimized), and Multi-AZ NAT Gateways for `prod` (high availability).

2. **Kubernetes Control Plane (EKS Module)**:
   - Managed EKS cluster control plane (Kubernetes v1.30).
   - IAM Role with `AmazonEKSClusterPolicy`.
   - Security group for cluster communication.

3. **Serverless Worker Nodes (Fargate Module)**:
   - EKS Fargate Pod Execution IAM Role (`AmazonEKSFargatePodExecutionRolePolicy`).
   - Fargate profiles for `kube-system` (required for system pods) and application namespaces (`default`, `dev-app`, `staging-app`, `prod-app`).

---

## 🛠️ Jenkins CI/CD Pipeline Flow

The included `Jenkinsfile` implements a interactive pipeline flow:

1. **Parameters Selection**:
   - **`ENVIRONMENT`**: Choice of `dev`, `staging`, `prod`.
   - **`ACTION`**: Choice of `plan`, `apply`, `destroy`.
2. **Stages**:
   - **Checkout**: Pulls latest code.
   - **Terraform Init**: Initializes plugins and backend.
   - **Terraform Validate**: Checks HCL code syntax.
   - **Terraform Plan**: Generates execution plan with environment `-var-file=environments/${ENVIRONMENT}.tfvars`.
   - **Manual Approval Gate**: Pauses pipeline and prompts administrator to approve before applying.
   - **Terraform Apply / Destroy**: Executes changes only upon user approval.

---

## 📌 Post-Deployment Step: CoreDNS on Fargate

EKS default CoreDNS deployment is configured for EC2 compute. To run CoreDNS on Fargate:

```bash
# 1. Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name dev-eks-fargate-cluster

# 2. Patch CoreDNS deployment to remove EC2 compute type annotation
kubectl patch deployment coredns -n kube-system --type json \
  -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'

# 3. Restart CoreDNS rollout
kubectl rollout restart deployment coredns -n kube-system
```

---

## 🧪 Local Testing

To test Terraform locally without Jenkins:

```bash
# Initialize
terraform init

# Plan for dev environment
terraform plan -var-file=environments/dev.tfvars

# Apply for dev environment
terraform apply -var-file=environments/dev.tfvars
```
