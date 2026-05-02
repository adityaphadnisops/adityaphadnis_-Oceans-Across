output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "tenant_instance_ids" {
  description = "EC2 instance IDs for tenant backend services"
  value       = module.tenants.instance_ids
}

output "tenant_security_group_ids" {
  description = "Security group IDs for tenant isolation"
  value       = module.tenants.tenant_security_group_ids
}

output "s3_bucket_name" {
  description = "Payroll documents bucket name"
  value       = module.storage.bucket_name
}

output "db_endpoint" {
  description = "Primary RDS PostgreSQL endpoint"
  value       = module.database.db_endpoint
}

output "db_name" {
  description = "RDS PostgreSQL database name"
  value       = module.database.db_name
}
