resource "aws_ecr_repository" "repositories" {
  for_each = { for combo in var.app_env_list : "${combo.app}-${combo.env}" => combo }

  name         = "${each.value.app}-${each.value.env}"
  force_delete = var.should_force_delete
}

resource "null_resource" "push_default_image" {
  for_each = aws_ecr_repository.repositories

# TODO: Create podman provider and rewrite this section 
  provisioner "local-exec" {
    command = <<EOT
	#Pull default image (nginx)
        podman pull nginx:latest

	# Tag the image for the ECR repository
	podman tag nginx:latest ${each.value.repository_url}:${local.timestamp_sanitized}

	# Login to AWS ECR
	aws ecr get-login-password --region us-east-1 | podman login --username AWS --password-stdin ${each.value.repository_url}

	# Push the image to ECR
	podman push ${each.value.repository_url}:latest
      EOT
  }

  depends_on = [aws_ecr_repository.repositories]
}

# If this does not work on Windows, use WSL to guarantee /tmp/ folder is available
resource "null_resource" "check_ecr_images" {
  for_each = { for repo in aws_ecr_repository.repositories : repo.name => repo }

  provisioner "local-exec" {
    command = <<EOT
    aws ecr describe-images --repository-name ${each.key} --region us-east-1 --query 'imageDetails' --output json > /tmp/ecr_image_check_${each.key}.json
    EOT
  }
}
