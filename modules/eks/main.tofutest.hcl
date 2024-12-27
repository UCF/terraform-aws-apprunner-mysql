#####################################################################
# main.tofutest.hcl                                                 #
#####################################################################
# Tests for Vitess EKS Cluster                                      #
#####################################################################

variables {
  applications = ["announcements", "template"]
  environments = ["dev", "test"]
  app_env_list = [
    { app = "announcements", env = "dev" },
    { app = "announcements", env = "test" },
    { app = "template", env = "dev" },
    { app = "template", env = "test" },
  ]
  passwords        = ["anndev", "anntest", "tempdev", "temptest"]
  ecr_repositories = ["announcements-dev", "announcements-test", "template-dev", "template-test"]
}

#######################################################################
# VPC Tests                                                           #
#######################################################################

run "vpc_is_set_up" {
  assert {
    condition     = aws_vpc.eks_vpc.cidr_block == "10.0.0.0/16"
    error_message = "VPC is not set up with cidr_block `10.0.0.0/16`."
  }
}

######################################################################
# Subnets                                                            #
######################################################################

run "eks_private_subnets_are_private" {
  assert {
    condition     = alltrue([for subnet in aws_subnet.private_eks_subnets : subnet.map_public_ip_on_launch == false])
    error_message = "Private subnets are not private."
  }
}

run "eks_public_subnet_is_in_vpc" {
  assert {
    condition     = aws_subnet.public_eks_subnet.vpc_id == aws_vpc.eks_vpc.id
    error_message = "EKS subnets not set up in VPC."
  }
}

#####################################################################
# Route Table, Association, and Internet Gateway Tests              #
#####################################################################

run "public_route_table_has_internet_gateway_id" {
  assert {
    condition     = alltrue([for route in aws_route_table.public.route : route.gateway_id == aws_internet_gateway.main.id])
    error_message = "Public Route Table does not have internet gateway id associated."
  }
}

run "route_table_associated_to_public_subnet" {
  assert {
    condition     = aws_route_table_association.public.subnet_id == aws_subnet.public_eks_subnet.id
    error_message = "Route Table is not associated with public subnet."
  }
}

####################################################################
# IAM Tests                                                        #
####################################################################

run "eks_cluster_assumes_role" {
  assert {
    condition = alltrue([for action in [
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
    ] : contains(data.aws_iam_policy_document.eks_cluster_allowances.statement[0].actions, action)])
    error_message = "Not all required actions are present in cluster allowances policy document."
  }

  assert {
    condition     = aws_iam_role_policy_attachment.eks_cluster_allowances.policy_arn == aws_iam_policy.eks_cluster_allowances.arn
    error_message = "EKS Cluster Policy not attached to cluster role"
  }

  assert {
    condition     = aws_iam_role_policy_attachment.eks_cluster_allowances.role == aws_iam_role.eks_cluster.name
    error_message = "EKS Cluster Role not attached in policy attachment."
  }
}

run "eks_node_policy_attached_to_node_role" {
  assert {
    condition = alltrue([for action in [
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
    ] : contains(data.aws_iam_policy_document.eks_node_allowances.statement[0].actions, action)])
    error_message = "Not all required actions are present in node allowances policy document."
  }

  assert {
    condition     = aws_iam_role_policy_attachment.eks_node.policy_arn == aws_iam_policy.eks_node_allowances.arn
    error_message = "EKS Node Policy not attached to cluster role"
  }

  assert {
    condition     = aws_iam_role_policy_attachment.eks_node.role == aws_iam_role.eks_node.name
    error_message = "EKS Node Role not attached in policy attachment."
  }
}

#######################################################################
# EKS Tests                                                           #
#######################################################################

run "eks_is_on_private_subnets" {
  assert {
    condition = aws_eks_cluster.vitess_cluster.vpc_config[0].subnet_ids == toset(aws_subnet.private_eks_subnets[*].id)
    error_message = "EKS cluster is not on private subnets"
  }
}
