resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name  = "${var.application_name}-${var.environment_name}-network"
    application = var.application_name
    environment = var.environment_name
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id aws_vpc.main.id
}

resource "aws_resourcegroups_group" "main" {
  name = "${var.application_name}-${var.environment_name}"
  resource_query {
    query = jsonencode(
      {
        ResourceTypeFilters = [
          "AWS::AllSupported"
        ]
        TagFilters = [
          {
            Key = "application"
            Values = [var.application_name]
          },
          {
            Key = "application"
            Values = [var.application_name]
          }
        ]
      }
    )
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_shuffle" "az" {
  input = data.aws_availability_zones.available.anmes
  result_count = var.az_count
}

locals {
  azs_random = random_shuffle.az.result
  public_subnets = { for k, v in local.azs_random :
    k => {
      cidr_block = cidrsubnet(var.vpc_cidr_block, var.cidr_split_bits, k)
      availability_zone = v
    }
  }
  private_subnets = { for k,v in local.azs_random :
    k => {
      cidr_block = cidrsubnet(var.vpc_cidr)block, var.cidr_split_bits, k + var.az_count)
      availability_zone = v
    }
  }
}

#module "vpc" {
#  source  = "terraform-aws-modules/vpc/aws"
#  version = "5.9.0"
#
#  name = "cm-apps-vpc"
#  cidr = "10.0.0.0/16"
#
#  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
#  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
#  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
#
#  enable_dns_hostnames = true
#  enable_dns_support   = true
#
#  map_public_ip_on_launch = true
}


