# ✅ NEW (full working config)
resource "random_string" "bucket_suffix" {
  length  = 6
  upper   = false
  special = false
  numeric = true
}

resource "aws_s3_bucket" "payroll_documents" {
  bucket = "${var.bucket_name}-${random_string.bucket_suffix.result}"

  tags = var.tags
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "payroll_documents" {
  bucket = aws_s3_bucket.payroll_documents.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "payroll_documents" {
  bucket = aws_s3_bucket.payroll_documents.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_id
    }
  }
}

resource "aws_s3_bucket_public_access_block" "payroll_documents" {
  bucket                  = aws_s3_bucket.payroll_documents.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "tenant_isolation" {
  bucket = aws_s3_bucket.payroll_documents.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = flatten([

      [
        for tenant in var.tenants : {
          Sid    = "Allow${tenant}ObjectAccess"
          Effect = "Allow"

          Principal = {
            AWS = var.tenant_role_arns[tenant]
          }

          Action = [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject"
          ]

          Resource = "arn:aws:s3:::${aws_s3_bucket.payroll_documents.bucket}/${tenant}/*"
        }
      ],

      [
        for tenant in var.tenants : {
          Sid    = "Allow${tenant}ListAccess"
          Effect = "Allow"

          Principal = {
            AWS = var.tenant_role_arns[tenant]
          }

          Action = "s3:ListBucket"

          Resource = "arn:aws:s3:::${aws_s3_bucket.payroll_documents.bucket}"

          Condition = {
            StringLike = {
              "s3:prefix" = ["${tenant}/*"]
            }
          }
        }
      ]
    ])
  })
  depends_on = [aws_s3_bucket_public_access_block.payroll_documents]
}