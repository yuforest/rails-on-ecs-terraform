variable "aws_region" {
  default = "ap-northeast-1"
}

variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "domain_name" {
  description = "ドメイン名 (example.comのような)"
  type        = string
}

variable "subdomain" {
  description = "サブドメイン (www や api など) 空の場合はルートドメイン"
  type        = string
  default     = ""
}

variable "ecs_alert_email_address" {
  description = "ECSのアラートを受け取るメールアドレス"
  type = string
}

variable "db_username" {
  type = string
}
variable "db_password" {
  type = string
}