variable "name" { type = string }
variable "ami_filter" { type = map(string) }
variable "instance_type" { type = string }
variable "subnet_id" { type = string }
variable "security_group_ids" { type = list(string) }
variable "iam_instance_profile" { type = string | null }
variable "tags" { type = map(string) default = {} }
