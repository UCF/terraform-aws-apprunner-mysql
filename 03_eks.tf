module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  subnet_ids = module.vpc.public_subnets
  vpc_id     = module.vpc.vpc_id

  eks_managed_node_groups = {
    node_group = {
      desired_size = var.desired_capacity
      max_size     = var.max_node_count
      min_size     = var.min_node_count

      instance_types = var.instance_type
    }
  }
}
