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
  default     = 2 
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

variable "node_image_type" {
  type = string
  default = "AL2_x86_64"
}

variable "node_size" {
  type = string
  default = "t3.small"
}

variable "k8s_namespace" {
  type = string
  default = "app"
}

variable "k8s_service_account_name" {
  type = string
  default = "app-service-account"
}
