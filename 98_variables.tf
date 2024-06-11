variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Public subnets CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "cm-cluster"
}

variable "cluster_version" {
  description = "EKS cluster version"
  default     = "1.30"
}

variable "desired_capacity" {
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
}

variable "state_bucket" {
  type    = string
  default = "cm-state-bucket"
}

variable "namespaces" {
  description = "List of Kubernetes namespaces"
  type        = list(string)
  default     = ["dev", "qa", "prod"]
}

variable "db_identifier" {
  description = "The RDS Instance identifier"
  default     = "my-rds-instance"
}

variable "db_name" {
  description = "The database name"
}

variable "db_username" {
  description = "The database username"
}

variable "db_password" {
  description = "The database password"
}

variable "s3_bucket" {
  description = "The S3 bucket to store the SQL file"
}

variable "sql_file" {
  description = "The SQL file name"
}

variable "key_name" {
  description = "The name of the key pair for SSH access"
}






