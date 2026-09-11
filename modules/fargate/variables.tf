variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for Fargate profiles"
  type        = list(string)
}

variable "fargate_profiles" {
  description = "Map of Fargate profiles with profile name and selectors (namespace & optional labels)"
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
