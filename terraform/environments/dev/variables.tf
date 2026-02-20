variable "project_name" {
  description = "Prefix for all resources"
  type        = string
  default     = "placeholder-project"
}

variable "vpc_cidr" {
  description = "Network CIDR used in dev"
  type        = string
  default     = "10.0.0.0/24"
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
