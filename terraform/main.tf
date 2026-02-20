locals {
  environment = terraform.workspace
}

module "vpc" {
  source = "./modules/vpc"

  environment = local.environment
}