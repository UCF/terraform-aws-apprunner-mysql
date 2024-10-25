variables {
  bucket_name         = "tofutestbucket"
  dynamodb_table_name = "tofutesttable"
}

run "verify_s3_bucket" {
  # Verify the s3 bucket for remote state exists
  assert {
    condition     = resource.aws_s3_bucket.state_bucket.id == var.bucket_name
    error_message = "S3 bucket ${var.bucket_name} does not exist or is not accessible"
  }
}

run "verify_dynamodb_table" {
  # Verify that the DynamoDV table for state locking exists"

  assert {
    condition     = resource.aws_dynamodb_table.lock_table.name == var.dynamodb_table_name
    error_message = "DynamoDB table ${var.dynamodb_table_name} does not exist or is not accessible"
  }
}


