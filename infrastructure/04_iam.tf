data "aws_iam_policy_document" "container_cluster_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "container_cluster" {
  name               = "eks-${var.application_name}-${var.environment_name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.container_cluster_assume_role.json
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.container_cluster.name
}

data "aws_iam_policy_document" "container_node_group" {

  statement {
    sid     = "EKSNodeAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "container_node_group" {
  name = "eks-${var.application_name}-${var.environment_name}-nodegroup-role"

  assume_role_policy = data.aws_iam_policy_document.container_node_group.json

  tags = {
    application = var.application_name
    environment = var.environment_name
  }
}

# EKS Worker Node
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.container_node_group.name
}

# CNI
resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.container_node_group.name
}

# ECR
resource "aws_iam_role_policy_attachment" "eks_ecr_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.container_node_group.name
}

# CloudWatch
resource "aws_iam_role_policy_attachment" "cloudwatch" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.container_node_group.name
}

# ALB
resource "aws_iam_role_policy_attachment" "alb" {
  policy_arn = aws_iam_policy.alb_controller.arn
  role       = aws_iam_role.container_node_group.name
}

resource "aws_iam_role" "alb_controller" {
  name = "aws-load-balancer-controller-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "alb_controller" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "Policy for the AWS Load Balancer Controller"
  policy      = file("${path.module}/files/alb-controller-policy.json")
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller.arn
}
