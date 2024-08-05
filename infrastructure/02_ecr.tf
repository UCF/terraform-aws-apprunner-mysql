locals {
  repository_list = ["announcements"]
  repositories    = { for name in local.repository_list : name => name }
}

resource "aws_ecr_repository" "main" {
  for_each = local.repositories

  name                 = "ecr-${var.application_name}-${var.environment_name}-${each.key}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  tags = {
    application = var.application_name
    environment = var.environment_name
  }
}

resource "aws_iam_group" "ecr_image_pushers" {
  name = "${var.application_name}-${var.environment_name}-ecr-image-pushers"
}

resource "aws_iam_group_policy" "ecr_image_pushers" {
  for_each = local.repositories
  name     = "${var.application_name}-${var.environment_name}-${each.key}-ecr-image-push-policy"
  group    = aws_iam_group.ecr_image_pushers.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ],
        Resource = aws_ecr_repository.main[each.key].arn
      }
    ]
  })
}

resource "aws_iam_group_membership" "ecr_image_pushers" {
  name  = "${var.application_name}-${var.environment_name}-ecr-image-push-membership"
  users = ["chandra"]
  group = aws_iam_group.ecr_image_pushers.name
}


