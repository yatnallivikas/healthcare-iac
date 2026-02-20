locals {
  environment  = terraform.workspace
  cluster_name = "healthcare-eks-${local.environment}"
}

module "vpc" {
  source = "./modules/vpc"

  environment  = local.environment
  cluster_name = local.cluster_name
}

module "iam" {
  source = "./modules/iam"

  cluster_name = local.cluster_name
  environment  = local.environment
}

module "security_group" {
  source = "./modules/security-group"

  cluster_name = local.cluster_name
  vpc_id       = module.vpc.vpc_id
}

module "eks" {
  source = "./modules/eks"

  cluster_name              = local.cluster_name
  cluster_version           = "1.29"
  subnet_ids                = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)
  private_subnet_ids        = module.vpc.private_subnet_ids
  cluster_role_arn          = module.iam.eks_cluster_role_arn
  node_role_arn             = module.iam.eks_node_role_arn
  cluster_security_group_id = module.security_group.cluster_security_group_id
  node_security_group_id    = module.security_group.node_security_group_id
  node_instance_types       = var.node_instance_types
  node_desired_size         = var.node_desired_size
  node_min_size             = var.node_min_size
  node_max_size             = var.node_max_size
}

module "ecr" {
  source      = "./modules/ecr"
  environment = local.environment
}