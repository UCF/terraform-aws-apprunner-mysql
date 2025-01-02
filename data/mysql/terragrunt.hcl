remote_state = {
    backend = "s3"
    generate = {
      path = "backend.tf"
      if_exists = "overwrite_terragrunt"
    }
    config = {
      bucket         = "cm-staging-tfstate"
      key            = "${path_relative_to_include()}/terraform.tfstate"
      region         = "us-east-1"
      encrypt        = true
      dynamodb_table = "staging-state-lock-table"
    }
}

terraform {
  after_hook "show_outputs" {
    commands = ["run-all apply"]
    execute = ["terragrunt", "run-all", "output"]
    run_on_error = true
  }
}
