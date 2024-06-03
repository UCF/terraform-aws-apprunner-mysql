terraform {
  backend "s3" {
    bucket  = "doc-20240506105257"
    key     = "terraform/state"
    region  = "us-east-1"
    encrypt = true
  }
}
