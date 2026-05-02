output "instance_ids" {
  description = "EC2 instance IDs created for tenant backend services"
  value       = aws_instance.tenant[*].id
}

output "tenant_security_group_ids" {
  description = "Security group IDs used to isolate tenant compute resources"
  value       = [for tenant in var.tenant_names : aws_security_group.tenant[tenant].id]
}

output "tenant_security_group_names" {
  description = "Tenant security group names"
  value       = [for tenant in var.tenant_names : aws_security_group.tenant[tenant].name]
}
