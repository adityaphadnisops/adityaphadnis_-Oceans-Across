variable "identifier" { type = string }
variable "username" { type = string }
variable "password" { type = string }
variable "subnet_ids" { type = list(string) }
variable "vpc_security_group_ids" { type = list(string) }
variable "instance_class" { type = string default = "db.t3.micro" }
variable "allocated_storage" { type = number default = 20 }

resource "aws_db_subnet_group" "default" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids
  tags = { Name = "${var.identifier}-subnet-group" }
}

# Two modes are supported:
# 1) Default (create_db = false): Terraform will NOT create the RDS instance. It will reference an existing DB via data source.
#    This avoids placing DB credentials into Terraform state and is the recommended production workflow for sensitive PII.
# 2) Optional create (create_db = true): Terraform will create the DB instance using the provided password. This WILL place the password in state
#    unless `allow_password_in_state` is explicitly set to true by an operator who understands the risk.

data "aws_db_instance" "existing" {
  count = var.create_db ? 0 : 1
  db_instance_identifier = var.identifier
}

resource "aws_db_instance" "this" {
  count = var.create_db ? 1 : 0
  identifier = var.identifier
  engine = "postgres"
  engine_version = "13"
  instance_class = var.instance_class
  allocated_storage = var.allocated_storage
  name = "appdb"
  username = var.username
  password = var.password
  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids = var.vpc_security_group_ids
  publicly_accessible = false
  skip_final_snapshot = var.skip_final_snapshot
  storage_encrypted = true
  kms_key_id = var.kms_key_id
  backup_retention_period = var.backup_retention_period
  deletion_protection = var.deletion_protection
  multi_az = var.enable_multi_az
  final_snapshot_identifier = "${var.identifier}-final"
  tags = merge({ Name = var.identifier }, var.tags)

  lifecycle {
    # Prevent accidental exposure of password in routine updates; operator must opt-in to allow password in state
    ignore_changes = var.allow_password_in_state ? [] : [password]
  }
}
