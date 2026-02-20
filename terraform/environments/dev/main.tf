// Environment wiring modules together so terraform plan remains local-only.
module "vpc" {
  source     = "../../modules/vpc"
  name       = var.project_name
  cidr_block = var.vpc_cidr
}

module "eks" {
  source          = "../../modules/eks"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids
  cluster_version = var.cluster_version
}

module "ecr" {
  source           = "../../modules/ecr"
  repository_name  = var.repository_name
  image_tag_mutability = "MUTABLE"
}

output "cluster_name" {
  description = "Surface placeholder cluster name for reference"
  value       = module.eks.cluster_name
}

output "ecr_repo_url" {
  description = "Surface placeholder repository URI"
  value       = module.ecr.repository_url
}
