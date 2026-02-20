variable "project_name" {
  description = "Prefix for all resources"
  type        = string
}

variable "vpc_cidr" {
  description = "Network CIDR used in dev"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for dev cluster"
  type        = string
  default     = "1.29"
}

variable "repository_name" {
  description = "ECR repo for microservice images"
  type        = string
  default     = "app-dev"
}
