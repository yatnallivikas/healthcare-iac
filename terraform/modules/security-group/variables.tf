variable "cluster_name" {
  description = "EKS cluster name for security group naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}
