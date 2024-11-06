terraform {
  required_version = "1.8.3"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "5.74.0"
    }

    mysql = {
      source  = "petoju/mysql"
      version = "3.0.65"
    }
  }
}
