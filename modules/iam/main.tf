resource "aws_iam_role" "tenant" {
  for_each = toset(var.tenant_names)

  name = "${each.key}-tenant-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "tenant_policy" {
  for_each = aws_iam_role.tenant

  name = "${each.key}-tenant-policy"
  role = each.value.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(

      # 🔐 S3 List
      [
        {
          Sid    = "S3TenantList"
          Effect = "Allow"
          Action = ["s3:ListBucket"]
          Resource = "arn:aws:s3:::${var.bucket_name}"
          Condition = {
            StringLike = {
              "s3:prefix" = ["${each.key}/*"]
            }
          }
        }
      ],

      # 🔐 S3 Object access
      [
        {
          Sid    = "S3TenantObjects"
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject"
          ]
          Resource = "arn:aws:s3:::${var.bucket_name}/${each.key}/*"
        }
      ],

      # 🔍 EC2 Describe
      [
        {
          Sid    = "DescribeEC2"
          Effect = "Allow"
          Action = ["ec2:DescribeInstances"]
          Resource = "*"
        }
      ],

      # 🔥 Secrets Manager (ONLY if ARN provided)
      var.db_secret_arn != "" ? [
        {
          Sid    = "SecretsManagerDBAccess"
          Effect = "Allow"
          Action = ["secretsmanager:GetSecretValue"]
          Resource = var.db_secret_arn
        }
      ] : []
    )
  })
}

resource "aws_iam_instance_profile" "tenant" {
  for_each = aws_iam_role.tenant

  name = "${each.key}-tenant-instance-profile"
  role = each.value.name
}