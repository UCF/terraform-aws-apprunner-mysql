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

variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
  default = "cm-appfolio"
}

variable "application_name" {
  description = "The name of the application"
  type = string
}

variable "environment_name" {
  description = "The name of the environment"
  type = string
}

