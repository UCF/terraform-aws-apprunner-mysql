##############################################################
# main.tf                                                    #
##############################################################


##############################################################
# ECR Resources                                              #
##############################################################

resource "aws_ecr_repository" "repositories" {
  for_each = { for combo in var.app_env_list : "${combo.app}-${combo.env}" => combo }

  name         = "${each.value.app}-${each.value.env}"
  force_delete = var.should_force_delete

  encryption_configuration {
    encryption_type = "AES256"
  }
}

# Permissions to comply with terrascan

resource "aws_ecr_repository_policy" "repositories_policy" {
  for_each = aws_ecr_repository.repositories

  repository = each.value.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPushPull"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage"
        ]
      }
    ]
  })
}



#############################################################
# Create default images to push to repos and local file     #
# for checking if those images were pushed successfully     #
#############################################################

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
