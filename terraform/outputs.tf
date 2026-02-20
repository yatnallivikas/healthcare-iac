output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for the EKS Kubernetes API server"
  value       = module.eks.cluster_endpoint
}

output "kubeconfig_command" {
  description = "Command to update kubeconfig for kubectl access"
  value       = "aws eks update-kubeconfig --region ap-south-1 --name ${module.eks.cluster_name}"
}
