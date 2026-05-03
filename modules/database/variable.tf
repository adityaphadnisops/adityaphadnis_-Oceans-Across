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

variable "kms_key_id" {
  description = "KMS key id for DB encryption"
  type        = string
  default     = ""
}

variable "skip_final_snapshot" {
  description = "Whether to skip final snapshot on destroy (false is safer)"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Enable deletion protection for DB instance"
  type        = bool
  default     = true
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "tags" {
  description = "Tags applied to DB resources"
  type        = map(string)
  default     = {}
}
