# ✅ ALB のセキュリティグループ
resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  description = "Allow HTTP/S traffic to ALB"
  vpc_id      = aws_vpc.main.id

  # HTTP (80) を許可
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS (443) を許可（証明書を使うなら）
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 全てのアウトバウンド通信を許可
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ✅ ECS タスク（コンテナ）のセキュリティグループ
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-security-group"
  description = "Allow traffic from ALB to ECS"
  vpc_id      = aws_vpc.main.id

  # ALB からの通信を許可（3000番ポート）
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]  # ALB からの通信を許可
  }

  # 全てのアウトバウンド通信を許可（DB や API にアクセス可能）
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ✅ RDS (データベース) のセキュリティグループ
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Allow access to the database from ECS"
  vpc_id      = aws_vpc.main.id

  # ECS からの通信を許可（PostgreSQL の場合は 5432, MySQL は 3306）
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]  # ECS からの通信を許可
  }

  # 全てのアウトバウンド通信を許可
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
