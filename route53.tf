# ✅ Route 53 のホストゾーンを取得（既存のドメインがある場合）
data "aws_route53_zone" "main" {
  name         = var.domain_name  # 🚨 自分のドメイン名に変更！
  private_zone = false
}

# ✅ ALB に紐づける A レコード（ドメインでアクセス可能にする）
resource "aws_route53_record" "alb_record" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.subdomain == "" ? var.domain_name : "${var.subdomain}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.rails.dns_name
    zone_id               = aws_lb.rails.zone_id
    evaluate_target_health = true
  }
}

# ✅ ACM (AWS Certificate Manager) で SSL 証明書を作成
resource "aws_acm_certificate" "cert" {
  domain_name       = "app.example.com"  # 🚨 証明書の対象ドメイン
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# ✅ 証明書の DNS 検証用レコードを Route 53 に登録
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.value]
  ttl     = 60
}

# ✅ 証明書の検証を完了
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}


