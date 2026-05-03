project = "payroll-dev"
region  = "us-east-1"
env     = "dev"

# Provide the ARN of an existing Secrets Manager secret holding DB credentials in JSON: {"username":"...","password":"..."}
# DO NOT put real secrets in this file in source control; replace with CI or local-only tfvars.
db_secret_arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:payroll-dev-db-ABC123"

# Backend and other sensitive values should be provided via environment or CI
