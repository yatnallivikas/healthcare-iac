output "cluster_security_group_id" {
  description = "Security group ID for the EKS cluster"
  value       = aws_security_group.eks_cluster.id
}

output "node_security_group_id" {
  description = "Security group ID for the EKS worker nodes"
  value       = aws_security_group.eks_node.id
}
