variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name of the payroll project used for tagging and resource naming"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "tenant_names" {
  description = "Tenant environments to create isolated backend compute resources for"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type for tenant backend services"
  type        = string
  default     = "t3.micro"
}

variable "bucket_name" {
  description = "Base name for the payroll documents S3 bucket"
  type        = string
  default     = "payroll-documents"
}

variable "db_username" {
  description = "Master username for the PostgreSQL database"
  type        = string
  default     = "payroll_admin"
}

variable "db_name" {
  description = "Primary database name for the payroll platform"
  type        = string
  default     = "payrolldb"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default = {
    Project     = "payroll-platform"
    Environment = "dev"
  }
}