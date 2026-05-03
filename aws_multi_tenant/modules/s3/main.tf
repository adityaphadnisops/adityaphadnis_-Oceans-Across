
variable "name" { type = string }
variable "kms_key_id" { type = string }
variable "tenants" { type = list(string) default = [] }
variable "tenant_role_arns" { type = map(string) default = {} }

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "this" {
  bucket = var.name
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
        kms_master_key_id = var.kms_key_id
      }
    }
  }
  tags = merge({ Name = var.name }, var.tags)
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
// Build a strict bucket policy with prefix-based tenant isolation and no public access.
locals {
  tenants_with_arns = [ for t in var.tenants : { tenant = t, arn = lookup(var.tenant_role_arns, t, "") } if lookup(var.tenant_role_arns, t, "") != "" ]

  statements = concat(
    [
      {
        Sid = "DenyInsecureTransport",
        Effect = "Deny",
        Principal = "*",
        Action = "s3:*",
        Resource = [ aws_s3_bucket.this.arn, "${aws_s3_bucket.this.arn}/*" ],
        Condition = { Bool = { "aws:SecureTransport" = false } }
      }
    ],
    flatten([ for t in local.tenants_with_arns : [
      {
        Sid = "AllowTenantObjects-${t.tenant}",
        Effect = "Allow",
        Principal = { AWS = t.arn },
        Action = [ "s3:GetObject", "s3:PutObject", "s3:DeleteObject" ],
        Resource = [ "${aws_s3_bucket.this.arn}/${t.tenant}/*" ]
      },
      {
        Sid = "AllowTenantList-${t.tenant}",
        Effect = "Allow",
        Principal = { AWS = t.arn },
        Action = [ "s3:ListBucket" ],
        Resource = [ aws_s3_bucket.this.arn ],
        Condition = { StringLike = { "s3:prefix" = [ "${t.tenant}/*" ] } }
      }
    ]])
  )

  bucket_policy = {
    Version = "2012-10-17",
    Statement = local.statements
  }
}

resource "aws_s3_bucket_policy" "tenant_policy" {
  bucket = aws_s3_bucket.this.id
  policy = jsonencode(local.bucket_policy)
  depends_on = [aws_s3_bucket_public_access_block.block]
}
