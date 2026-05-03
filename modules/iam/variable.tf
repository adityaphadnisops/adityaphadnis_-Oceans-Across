variable "tenant_names" {
  description = "List of tenant environments to isolate at the IAM level"
  type        = list(string)
}

variable "bucket_name" {
  description = "Base bucket name for tenant-scoped S3 access"
  type        = string
}

# 🔥 IMPORTANT FIX
variable "db_secret_arn" {
  description = "ARN of the Secrets Manager secret containing DB credentials"
  type        = string
}