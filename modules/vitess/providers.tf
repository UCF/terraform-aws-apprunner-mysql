provider "aws" {
  region = var.region
}

# Configure the Kubernetes provider using the EKS cluster details
provider "kubernetes" {
  host                   = var.vitess_cluster_host
  token                  = var.vitess_cluster_token
  cluster_ca_certificate = var.vitess_cluster_ca_certificate
}

#provider "mysql" {
#  endpoint = "${aws_eks_cluster.vitess_cluster.endpoint}:15999"
#  username = "admin"
#  password = var.adminpw
#}
