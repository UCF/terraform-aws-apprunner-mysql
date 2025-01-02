variable "region" {
  type    = string
  default = "us-east-1"
}

variable "adminpw" {
  type = string
}

variable "app_env_list" {
  type = list(object({
    app = string
    env = string
  }))
  description = "The App-Env List imported from the appenvlist module"
}

variable "ecr_repositories" {
  type = list(string)
}

variable "passwords" {
  type = list(string)
}

variable "vitess_cluster_host" {
  type = string
}

variable "vitess_cluster_token" {
  type = string
}

variable "vitess_cluster_ca_certificate" {
  type = string
}
