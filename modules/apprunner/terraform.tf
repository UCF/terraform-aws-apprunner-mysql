#################################################################
# terraform.tf                                                  #
#################################################################
# This file adds the 'terraform' provider version for tflint    #
# compliance. Note the version is the version number for        #
# for OpenTofu, which we are using to build this module, not    #
# Terraform.                                                    #
#################################################################

terraform {
  required_version = ">= 1.8.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.73.0"
    }
  }
}
