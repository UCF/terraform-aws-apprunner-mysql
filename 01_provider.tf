provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host = module.eks.cluster_endpoint
}

terraform {
  required_version = "~> 1.9"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.31.0"
    }
  }
}
