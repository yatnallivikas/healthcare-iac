variable "cluster_version" {
  description = "Desired Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "subnet_ids" {
  description = "Private subnet IDs used by worker nodes"
  type        = list(string)
  default     = ["subnet-private-a", "subnet-private-b"]
}

variable "vpc_id" {
  description = "Associated VPC ID"
  type        = string
  default     = "vpc-PLACEHOLDER"
}
