data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  bucket_prefix_arns = { for t in var.tenants : t => "${var.bucket_arn}/${t}/*" }
  tenants_with_arns   = [ for t in var.tenants : t if contains(keys(var.tenant_role_arns), t) && var.tenant_role_arns[t] != "" ]
}

resource "aws_iam_role" "tenant_role" {
  for_each = toset(var.tenants)
  name = "tenant-${each.key}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
  tags = merge(var.tags, { Tenant = each.key })
}

resource "aws_iam_policy" "tenant_policy" {
  for_each = toset(var.tenants)
  name = "tenant-${each.key}-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "S3ObjectsAccess",
        Effect = "Allow",
        Action = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
        Resource = [ local.bucket_prefix_arns[each.key] ]
      },
      {
        Sid = "S3ListBucket",
        Effect = "Allow",
        Action = ["s3:ListBucket"],
        Resource = [ var.bucket_arn ],
        Condition = {
          StringLike = { "s3:prefix" = ["${each.key}/*"] }
        }
      },
      {
        Sid = "EC2Describe",
        Effect = "Allow",
        Action = ["ec2:DescribeInstances"],
        Resource = ["*"]
      },
      {
        Sid = "SecretsManagerAccess",
        Effect = "Allow",
        Action = ["secretsmanager:GetSecretValue"],
        Resource = [ var.db_secret_arn ]
      },
      {
        Sid = "KmsUse",
        Effect = "Allow",
        Action = ["kms:Decrypt","kms:GenerateDataKey"],
        Resource = [ var.kms_key_arn ]
      }
    ]
  })
  tags = merge(var.tags, { Tenant = each.key })
}

resource "aws_iam_role_policy_attachment" "attach" {
  for_each = toset(var.tenants)
  role       = aws_iam_role.tenant_role[each.key].name
  policy_arn = aws_iam_policy.tenant_policy[each.key].arn
}

resource "aws_iam_role_policy_attachment" "ssm_managed" {
  for_each = toset(var.tenants)
  role = aws_iam_role.tenant_role[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "profile" {
  for_each = toset(var.tenants)
  name = "tenant-${each.key}-profile"
  role = aws_iam_role.tenant_role[each.key].name
}

# Create KMS grants for tenant roles to allow use of the key without widening key policy
resource "aws_kms_grant" "tenant_grant" {
  for_each = aws_iam_role.tenant_role
  name = "grant-${each.key}"
  key_id = var.kms_key_id
  grantee_principal = each.value.arn
  operations = ["Encrypt","Decrypt","GenerateDataKey","DescribeKey","ReEncryptFrom","ReEncryptTo"]
}
