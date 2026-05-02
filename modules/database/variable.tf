variable "project_name" {
  description = "Project name used for database tagging"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the database security group is created"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the RDS subnet group"
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "Security groups allowed to connect to the database"
  type        = list(string)
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
}

variable "db_name" {
  description = "Primary database name"
  type        = string
}
