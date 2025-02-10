# ✅ ECS タスク実行ロール（ECS が ECR からイメージを取得 & CloudWatch ログにアクセス）
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

# ✅ タスク実行ロールのポリシー（ECR & CloudWatch へのアクセス）
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ✅ ECS タスク用 IAM ロール（アプリが AWS サービスにアクセスする場合）
resource "aws_iam_role" "ecs_task_role" {
  name = "ecsTaskRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

# ✅ ECS タスク用のカスタムポリシー（例: S3 や SSM にアクセス）
resource "aws_iam_policy" "ecs_task_custom_policy" {
  name        = "ecsTaskCustomPolicy"
  description = "Custom permissions for ECS task"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject"]
        Resource = "arn:aws:s3:::your-bucket-name/*"
      },
      {
        Effect   = "Allow"
        Action   = ["ssm:GetParameter"]
        Resource = "arn:aws:ssm:ap-northeast-1:YOUR_ACCOUNT_ID:parameter/YOUR_PARAMETER_NAME"
      }
    ]
  })
}

# ✅ ECS タスクロールにカスタムポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "ecs_task_role_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_custom_policy.arn
}
