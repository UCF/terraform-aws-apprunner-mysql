###########################################################################
# main.tf                                                   		          #
###########################################################################
# Creates necessary AWS infrastructure for a Vitess ECS cluster           #
###########################################################################

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

###########################################################################
# VPC                                                                     #
###########################################################################

resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
}

###########################################################################
# Subnets                                                                 #
###########################################################################

resource "aws_subnet" "public_eks_subnet" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = "10.0.0.0/24"
}

resource "aws_subnet" "private_eks_subnets" {
  count                   = 2
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = false
}

##########################################################################
# Route Table, Association, and Internet Gateway                         #
##########################################################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.eks_vpc.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_eks_subnet.id
  route_table_id = aws_route_table.public.id
}

##########################################################################
# IAM                                                                    #
##########################################################################

data "aws_iam_policy_document" "eks_cluster_role_assumption" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "eks_cluster_allowances" {
  statement {
    actions = [
      "eks:CreateCluster",
      "eks:DescribeCluster",
      "eks:DeleteCluster",
      "eks:UpdateClusterConfig",
      "eks:UpdateClusterVersion",
      "eks:ListClusters",
      "eks:TagResource",
      "eks:UntagResource",
      "eks:ListNodegroups",
      "eks:DescribeNodegroup",
      "eks:CreateNodegroup",
      "eks:DeleteNodegroup",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "eks_node_role_assumption" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "eks_node_allowances" {
  statement {
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeVolumes",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "ec2:CreateTags",
      "ec2:RunInstances",
      "ec2:TerminateInstances",
      "eks:DescribeNodegroup",
      "eks:ListNodegroups",
      "eks:UpdateNodegroupConfig",
      "eks:DescribeCluster",
      "eks:ListClusters",
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:UpdateAutoScalingGroup",
      "autoscaling:CreateAutoScalingGroup",
      "autoscaling:DeleteAutoScalingGroup"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "vitess_operator_role_assumption" {

}

resource "aws_iam_role" "eks_cluster" {
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_role_assumption.json
}

resource "aws_iam_policy" "eks_cluster_allowances" {
  policy = data.aws_iam_policy_document.eks_cluster_allowances.json
}

resource "aws_iam_role_policy_attachment" "eks_cluster_allowances" {
  policy_arn = aws_iam_policy.eks_cluster_allowances.arn
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_policy" "eks_node_allowances" {
  policy = data.aws_iam_policy_document.eks_node_allowances.json
}

resource "aws_iam_role" "eks_node" {
  assume_role_policy = data.aws_iam_policy_document.eks_node_role_assumption.json
}

resource "aws_iam_role_policy_attachment" "eks_node" {
  policy_arn = aws_iam_policy.eks_node_allowances.arn
  role       = aws_iam_role.eks_node.name
}

###############################################################################
#  Vitess Cluster                                                             #
###############################################################################

resource "aws_eks_cluster" "vitess_cluster" {
  name     = "vitess-cluster"
  role_arn = aws_iam_role.eks_cluster.arn
  vpc_config {
    subnet_ids = aws_subnet.private_eks_subnets[*].id
  }
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_allowances]
}

data "aws_eks_cluster" "vitess_cluster" {
  name = aws_eks_cluster.vitess_cluster.name
}

data "aws_eks_cluster_auth" "vitess_cluster" {
  name = aws_eks_cluster.vitess_cluster.name
}


