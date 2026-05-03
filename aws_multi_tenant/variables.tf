variable "project" {
  type    = string
  default = "aws-multitenant"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "availability_zones" {
  type    = list(string)
  default = []
}

variable "admin_cidr" {
  type    = string
  default = ""
  description = "Admin/SSH CIDR - set to your admin IP (e.g. 203.0.113.4/32). Empty disables SSH ingress."
}

variable "tenants" {
  type    = list(string)
  default = ["company", "bureau", "employee"]
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "db_username" {
  type    = string
  default = "dbadmin"
}

variable "db_secret_arn" {
  type        = string
  description = "(REQUIRED) ARN of the existing Secrets Manager secret containing DB credentials. Terraform will READ this secret and will fail if it's missing."
}

// Enforce that secrets are provided via Secrets Manager only
validation {
  condition     = length(trim(var.db_secret_arn)) > 0
  error_message = "You must provide `db_secret_arn` pointing to an existing Secrets Manager secret; do NOT use plaintext passwords or tfvars for secrets."
}

variable "tags" {
  type = map(string)
  default = {}
}

variable "env" {
  type = string
  default = "dev"
}
