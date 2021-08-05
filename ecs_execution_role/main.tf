
resource "aws_iam_role_policy" "ecs-execute-task-policy" {
  name = "ecs_execution_policy"
  role = aws_iam_role.role.id  
  policy = jsonencode(
  {
    Version = "2012-10-17",
    Statement = [
        {
            Effect = "Allow",
            Action = [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            Resource = "*"
        }
    ]
  }
  )
}

resource "aws_iam_role" "role" {
  name = "ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}