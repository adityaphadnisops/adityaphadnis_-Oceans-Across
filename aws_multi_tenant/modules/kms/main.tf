variable "alias_name" { type = string }

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "this" {
  description             = "KMS key for encrypting RDS and S3 in multi-tenant payroll platform"
  deletion_window_in_days = 30
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AllowAccountAdmins"
        Effect = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action = [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:ScheduleKeyDeletion"
        ]
        Resource = "*"
      },
      {
        Sid = "AllowServicesUseKey"
        Effect = "Allow"
        Principal = { Service = [ "rds.amazonaws.com", "s3.amazonaws.com" ] }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
  tags = merge({ Name = var.alias_name }, var.tags)
}

resource "aws_kms_alias" "alias" {
  name          = "alias/${var.alias_name}"
  target_key_id = aws_kms_key.this.key_id
}
