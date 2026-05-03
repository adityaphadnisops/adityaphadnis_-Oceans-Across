# 🔐 Secret ARN (safe to expose)
output "db_secret_arn" {
  description = "ARN of the Secrets Manager secret holding DB credentials"
  value       = aws_secretsmanager_secret.db.arn
}

# RDS Instance ID
output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.postgres.id
}

# RDS Endpoint
output "db_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.postgres.endpoint
}

# Database Name
output "db_name" {
  description = "RDS database name"
  value       = aws_db_instance.postgres.db_name
}

# Username (safe)
output "db_master_username" {
  description = "Database master username"
  value       = aws_db_instance.postgres.username
}

# ❌ DO NOT OUTPUT PASSWORD
# Password is stored securely in AWS Secrets Manager