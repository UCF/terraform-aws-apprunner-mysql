resource "aws_security_group" "eks_cluster" {
  name        = "eks-cluster-sg"
  vpc_id      = aws_vpc.main.id
  description = "Security group for EKS cluster control plane"

  ingress {
    description = "Allow all traffic from worker nodes"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db_sg" {
  name_prefix = "db-sg-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "cluster_nodes" {
  name = "${var.application_name}-${var.environment_name}-cluster-nodes"
  vpc_id = aws_vpc.main.id

  egress {
    from_port = 0
    to_port = 0

    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
