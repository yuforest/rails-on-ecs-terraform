# ALB の作成
resource "aws_lb" "rails" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public[*].id
}

# ターゲットグループ
resource "aws_lb_target_group" "rails" {
  name        = "${var.app_name}-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}

# リスナー（HTTP:80 → Rails のポート 3000 に転送）
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.rails.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rails.arn
  }
}

# ✅ HTTPS 用の ALB リスナー（SSL 証明書を使用）
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.rails.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rails.arn
  }
}