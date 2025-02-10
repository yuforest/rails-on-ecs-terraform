# ✅ CloudWatch Logs グループ（ECS のログ出力先）
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/rails-app"
  retention_in_days = 7  # 7日間保持（変更可能）

  tags = {
    Name = "ecs-logs"
  }
}

# ✅ ECS の CloudWatch メトリクス監視 (CPU 使用率)
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "ECS-CPU-High"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace          = "AWS/ECS"
  period             = 300
  statistic          = "Average"
  threshold          = 80  # CPU 使用率 80% 超えでアラート
  alarm_description  = "ECS の CPU 使用率が 80% を超えました"
  alarm_actions      = [aws_sns_topic.ecs_alerts.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.rails_cluster.name
    ServiceName = aws_ecs_service.rails.name
  }
}

# ✅ ECS の CloudWatch メトリクス監視 (メモリ使用率)
resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  alarm_name          = "ECS-Memory-High"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace          = "AWS/ECS"
  period             = 300
  statistic          = "Average"
  threshold          = 80  # メモリ使用率 80% 超えでアラート
  alarm_description  = "ECS のメモリ使用率が 80% を超えました"
  alarm_actions      = [aws_sns_topic.ecs_alerts.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.rails_cluster.name
    ServiceName = aws_ecs_service.rails.name
  }
}

# ✅ SNS トピック（アラートの通知先）
resource "aws_sns_topic" "ecs_alerts" {
  name = "ecs-alerts"
}

# ✅ SNS のサブスクリプション（メール通知）
resource "aws_sns_topic_subscription" "ecs_alert_email" {
  topic_arn = aws_sns_topic.ecs_alerts.arn
  protocol  = "email"
  endpoint  = var.ecs_alert_email_address  # 受信したいメールアドレス
}
