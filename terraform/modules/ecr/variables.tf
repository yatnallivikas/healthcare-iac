variable "repository_name" {
  description = "Logical ECR repository name"
  type        = string
  default     = "app-placeholder"
}

variable "image_tag_mutability" {
  description = "Tag mutability policy"
  type        = string
  default     = "MUTABLE"
}
