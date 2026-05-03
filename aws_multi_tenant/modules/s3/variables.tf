variable "name" { type = string }
variable "kms_key_id" { type = string }
variable "tenants" { type = list(string) default = [] }
variable "tenant_role_arns" { type = map(string) default = {} }
variable "tags" { type = map(string) default = {} }
