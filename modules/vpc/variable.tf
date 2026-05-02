variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
}

variable "vpc_cidr" {
  description = "Primary VPC CIDR block (e.g. 10.0.0.0/16)"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets (order must match availability_zones)"
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) > 0
    error_message = "public_subnet_cidrs must contain at least one CIDR block"
  }
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets (order must match availability_zones)"
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_cidrs) > 0
    error_message = "private_subnet_cidrs must contain at least one CIDR block"
  }
}

variable "availability_zones" {
  description = "List of availability zones to place subnets in"
  type        = list(string)

  validation {
    condition = (
      length(var.availability_zones) > 0 &&
      length(var.availability_zones) == length(var.public_subnet_cidrs) &&
      length(var.availability_zones) == length(var.private_subnet_cidrs)
    )
    error_message = "availability_zones length must match public and private subnet CIDR lists"
  }
}
