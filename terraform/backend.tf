terraform {
  backend "s3" {
    bucket  = "vikas-healthcare-tf-state-2026-xyz123"
    key     = "infra/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}
