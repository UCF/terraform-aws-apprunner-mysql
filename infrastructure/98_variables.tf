variable "primary_region" {
  type        = string
  description = "Primary region for account activity"
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "az_count" {
  type        = number
  description = "Count for availability zones"
  default     = 1
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "cm-appfolio"
}

variable "cluster_version" {
  type        = number
  description = "EKS cluster version"
  default     = "1.29"
}

variable "desired_capacity" {
  type        = number
  description = "Desired number of worker nodes"
  default     = 3
}

variable "min_node_count" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 2
}

variable "max_node_count" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4
}

variable "instance_type" {
  description = "EC2 instance type for worker nodes"
  default     = ["t2.small"]
  type        = list(any)
}

variable "db_name" {
  description = "The database name"
  type        = string
}

variable "db_username" {
  description = "The database username"
  type        = string
}

variable "db_password" {
  description = "The database password"
  type        = string
}

