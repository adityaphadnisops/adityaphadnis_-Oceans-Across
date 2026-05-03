output "tenant_sg_ids" {
  value = { for k, sg in aws_security_group.tenant : k => sg.id }
}

output "rds_sg_id" {
  value = aws_security_group.rds.id
}
