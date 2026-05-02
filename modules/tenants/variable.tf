variable "project_name" {
  description = "Project name used for resource tags"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where tenant compute instances run"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for tenant backend compute"
  type        = list(string)
}

variable "instance_profile_names" {
  description = "List of IAM instance profiles for each tenant instance"
  type        = list(string)
}

variable "tenant_names" {
  description = "Tenant names for compute isolation"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type for tenant backend services"
  type        = string
}
