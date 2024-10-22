remote_state {
  backend = "s3"
  generate = {
    path = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "cm-state-${get_aws_account_id()}"
    key = "${path_relative_to_include()}/infrastructure/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "cm-state-lock-table"
  }
}

