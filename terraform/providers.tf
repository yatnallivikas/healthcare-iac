// Provider configuration kept simple so terraform init is safe locally.
provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region for deploying EKS platform"
  type        = string
  default     = "us-east-1" // TODO: change to desired region
}
