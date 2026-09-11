# IAM Role for EKS Fargate Pod Execution
resource "aws_iam_role" "fargate_pod_execution" {
  name = "${var.cluster_name}-fargate-pod-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks-fargate-pods.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "fargate_pod_execution" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_pod_execution.name
}

# Optional policy attachment for cloudwatch log routing from Fargate pods
resource "aws_iam_role_policy_attachment" "fargate_cw_logs" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.fargate_pod_execution.name
}

# AWS EKS Fargate Profiles
resource "aws_eks_fargate_profile" "this" {
  for_each               = var.fargate_profiles
  cluster_name           = var.cluster_name
  fargate_profile_name   = "${var.environment}-${each.key}"
  pod_execution_role_arn = aws_iam_role.fargate_pod_execution.arn
  subnet_ids             = var.private_subnet_ids

  selector {
    namespace = each.value.namespace
    labels    = each.value.labels
  }

  tags = {
    Environment = var.environment
    Profile     = each.key
  }

  depends_on = [
    aws_iam_role_policy_attachment.fargate_pod_execution
  ]
}
