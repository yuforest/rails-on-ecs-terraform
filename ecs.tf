# ✅ ECS クラスターを作成
resource "aws_ecs_cluster" "rails_cluster" {
  name = "${var.app_name}-cluster"
}

# ✅ ECS タスク定義（コンテナの設定）
resource "aws_ecs_task_definition" "rails" {
  family                   = "rails-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]  # Fargate で動作
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "rails-app"
      image     = "${aws_ecr_repository.rails_app.repository_url}:latest"
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      environment = [
        { name = "RAILS_ENV", value = "production" },
        { name = "DATABASE_URL", value = "postgres://${aws_db_instance.postgres.username}:${aws_db_instance.postgres.password}@${aws_db_instance.postgres.endpoint}/${aws_db_instance.postgres.db_name}" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/rails-app"
          awslogs-region        = "ap-northeast-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# ✅ ECS サービス（タスクを実行・スケーリング）
resource "aws_ecs_service" "rails" {
  name            = "rails-service"
  cluster         = aws_ecs_cluster.rails_cluster.id
  task_definition = aws_ecs_task_definition.rails.arn
  desired_count   = 1  # 最初は 1 インスタンスで開始
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.rails.arn
    container_name   = "rails-app"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.https]
}
