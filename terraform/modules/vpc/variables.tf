variable "name" {
  description = "Base name for networking resources"
  type        = string
  default     = "eks-skeleton"
}

variable "cidr_block" {
  description = "CIDR block reserved for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
