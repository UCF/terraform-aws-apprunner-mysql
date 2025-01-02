output "vitess_cluster_host" {
  value = data.aws_eks_cluster.vitess_cluster.endpoint
}

output "vitess_cluster_token" {
  value = nonsensitive(data.aws_eks_cluster_auth.vitess_cluster.token)
}

output "vitess_cluster_ca_certificate" {
  value = base64decode(data.aws_eks_cluster.vitess_cluster.certificate_authority[0].data)
}
