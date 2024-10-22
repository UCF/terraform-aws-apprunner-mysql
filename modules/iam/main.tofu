resource "aws_iam_role" "apprunner_role" {
  name = "apprunner-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_iam_policy" "ecr_access_policy" {
  name = "apprunner-ecr-access-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:DescribeImages",
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = "ecr:GetAuthorizationToken",
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "ecr-public:GetDownloadUrlForLayer",
          "ecr-public:BatchCheckLayerAvailability",
          "ecr-public:BatchGetImage",
          "ecr-public:DescribeRepositories",
          "ecr-public:GetRepositoryPolicy",
          "ecr-public:ListTagsForResource",
          "ecr-public:DescribeImages",
          "ecr-public:ListImages",
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = "ecr-public:GetAuthorizationToken",
        Resource = "*"
      }
    ]
  })
}

 
resource "aws_iam_role_policy_attachment" "apprunner_ecr_policy_attach" {
  role       = aws_iam_role.apprunner_role.name
  policy_arn = aws_iam_policy.ecr_access_policy.arn
}
