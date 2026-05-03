variable "tenants" { type = list(string) }
variable "bucket_arn" { type = string }
variable "kms_key_arn" { type = string }
variable "kms_key_id" { type = string }
variable "db_secret_arn" { type = string default = "" }
variable "tenant_role_arns" { type = map(string) default = {} }
variable "project" { type = string }
variable "tags" { type = map(string) default = {} }

