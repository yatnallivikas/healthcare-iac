terraform {
  backend "s3" {
    bucket         = "vikas-healthcare-tf-state-2026-xyz123"
    key            = "global/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}