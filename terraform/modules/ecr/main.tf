resource "aws_ecr_repository" "app" {
  name                 = "healthcare-app-${var.environment}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Service     = "healthcare-app"
    Environment = var.environment
  }
}