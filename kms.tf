# KMS キーの作成
resource "aws_kms_key" "ecr" {
  description             = "ECR image encryption key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "ecr" {
  name          = "alias/ecr-key"
  target_key_id = aws_kms_key.ecr.key_id
}
