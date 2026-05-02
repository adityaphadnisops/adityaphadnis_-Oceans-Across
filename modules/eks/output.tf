output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.main.id
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority" {
  description = "EKS cluster CA data"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN used by EKS control plane"
  value       = aws_iam_role.cluster.arn
}

output "node_iam_role_arn" {
  description = "IAM role ARN used by EKS worker nodes"
  value       = aws_iam_role.node.arn
}
