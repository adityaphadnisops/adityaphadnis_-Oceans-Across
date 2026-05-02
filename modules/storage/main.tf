resource "random_string" "bucket_suffix" {
  length  = 6
  upper   = false
  special = false
  numeric = true
}

resource "aws_s3_bucket" "payroll_documents" {
  bucket = "${var.bucket_name}-${random_string.bucket_suffix.result}"

  tags = {
    Name = var.bucket_name
  }
}

resource "aws_s3_bucket_acl" "payroll_documents" {
  bucket = aws_s3_bucket.payroll_documents.id
  acl    = "private"
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
      sse_algorithm = "AES256"
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
