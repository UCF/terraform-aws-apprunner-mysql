terraform {
  required_version = ">=1.8.3"
}

provider "aws" {
  region = var.region
}


module "appenvlist" {
  source = "../appenvlist"

  applications = var.applications
  environments = var.environments
}

resource "aws_ecr_repository" "repositories" {
  for_each = { for combo in module.appenvlist.app_env_list : "${combo.app}-${combo.env}" => combo }
  
  name         = "${each.value.app}-${each.value.env}"
  force_delete = true
}

resource "null_resoure" "push_default_image" {
  for_each = aws_ecr_repository.repositories

  provisioner "local-exec" {
    command = <<EOT
	#Pull default image (nginx)
        podman pull nginx:latest

	# Tag the image for the ECR repository
	podman tag nginx:latest ${each.value.repository_url}:latest

	# Login to AWS ECR
	aws ecr get-login-password --region us-east-1 | podman login --username AWS --password-stdin ${each.value.repository_url}

	# Push the image to ECR
	podman push ${each.value.repository_url}:latest
      EOT
  }

  depends_on = [aws_ecr_repository.repositories]
}
