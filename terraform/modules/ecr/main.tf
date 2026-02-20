resource "aws_ecr_repository" "patient" {
  name                 = "healthcare-patient-service-${var.environment}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "patient-service"
    Environment = var.environment
  }
}

resource "aws_ecr_repository" "appointment" {
  name                 = "healthcare-appointment-service-${var.environment}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "appointment-service"
    Environment = var.environment
  }
}