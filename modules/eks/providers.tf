provider "aws" {
  region = var.region
}

# Configure the Kubernetes provider using the EKS cluster details
provider "kubernetes" {
  host                   = data.aws_eks_cluster.vitess_cluster.endpoint
  token                  = data.aws_eks_cluster_auth.vitess_cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.vitess_cluster.certificate_authority[0].data)
}

provider "mysql" {
  endpoint = "${aws_eks_cluster.vitess_cluster.endpoint}:15999"
  username = "admin"
  password = var.adminpw
}
