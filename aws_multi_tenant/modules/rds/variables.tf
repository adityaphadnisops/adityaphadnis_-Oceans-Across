variable "identifier" { type = string }
variable "username" { type = string }
// NOTE: Do NOT set passwords in Terraform variables. Use Secrets Manager and set `create_db = false` in prod.
variable "password" { type = string default = "" }
variable "subnet_ids" { type = list(string) }
variable "vpc_security_group_ids" { type = list(string) }
variable "instance_class" { type = string default = "db.t3.micro" }
variable "allocated_storage" { type = number default = 20 }
variable "kms_key_id" { type = string default = "" }
variable "backup_retention_period" { type = number default = 7 }
variable "deletion_protection" { type = bool default = true }
variable "enable_multi_az" { type = bool default = false }
variable "skip_final_snapshot" { type = bool default = false }
variable "create_db" { type = bool default = false }
variable "allow_password_in_state" { type = bool default = false }
variable "tags" { type = map(string) default = {} }
