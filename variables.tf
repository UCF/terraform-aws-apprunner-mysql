variable "region" {
  type = string
  default = "us-east-1"
}

variable "cluster-name" {
  type = string
  default = "cm-cluster"
}

variable "k8s_version" {
  type = string
}

variable "release_version" {
  type = string
}

variable "min_node_count" {
  type = number
  default = 3
}

variable max_node_count" {
  type = number
  default = 9
}
