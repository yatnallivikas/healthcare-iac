variable "cluster_name" {
  description = "EKS cluster name, used for IAM role naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}
