variable "primary_region" {
  type        = string
  description = "Primary region for account activity"
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "cm-appfolio"
}

variable "namespace" {
  description = "Name of namespace"
  type        = string
  default     = "app"
}
