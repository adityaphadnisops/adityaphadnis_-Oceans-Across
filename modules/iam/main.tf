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
    Statement = [
      {
        Sid    = "S3TenantAccess"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::${var.bucket_name}"
        Condition = {
          StringLike = {
            "s3:prefix" = ["${each.key}/*"]
          }
        }
      },
      {
        Sid    = "S3TenantObjects"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::${var.bucket_name}/${each.key}/*"
      },
      {
        Sid    = "DescribeEC2"
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "tenant" {
  for_each = aws_iam_role.tenant

  name = "${each.key}-tenant-instance-profile"
  role = each.value.name
}
