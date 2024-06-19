provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host = module.eks.cluster_endpoint

}

