output "cluster_name" {
  value = var.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "region" {
  value = var.region
}

output "db_instance_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "eks_connect" {
  value = "aws eks --region us-east-1 update-kubeconfig --name ${module.eks.cluster_name}"
}

output "argocd_initial_admin_secret" {
  value = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d"
}
