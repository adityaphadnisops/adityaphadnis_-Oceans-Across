variable "bucket_name" {
  description = "Base name for the payroll documents bucket"
  type        = string
}

# 🔥 ADD THESE (delete mat karna upar wala)

variable "kms_key_id" {
  type = string
}

variable "tenants" {
  type = list(string)
}

variable "tenant_role_arns" {
  type = map(string)
}

variable "tags" {
  type = map(string)
}