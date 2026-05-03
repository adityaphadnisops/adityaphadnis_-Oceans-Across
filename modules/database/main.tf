resource "aws_db_subnet_group" "default" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "Database security group allowing tenant backend access"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.project_name}-db-sg"
    Environment = "payroll"
  }
}

resource "aws_security_group_rule" "db_ingress" {
  count                    = length(var.allowed_security_group_ids)
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = var.allowed_security_group_ids[count.index]
}

resource "aws_security_group_rule" "db_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.db.id
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!@#$%&*()-_=+"
}

resource "aws_secretsmanager_secret" "db" {
  name        = "${var.project_name}-db-credentials"
  description = "RDS credentials for ${var.project_name} (managed by Terraform)"
  tags        = merge({ Name = "${var.project_name}-db-secret" }, var.tags)
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id     = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({ username = var.db_username, password = random_password.db_password.result })
}

resource "aws_db_instance" "postgres" {
  identifier              = "${var.project_name}-payroll-db"
  engine                  = "postgres"
  engine_version          = "14"
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  storage_type            = "gp3"
  username                = var.db_username
  password                = jsondecode(aws_secretsmanager_secret_version.db.secret_string)["password"]
  db_name                 = var.db_name
  db_subnet_group_name    = aws_db_subnet_group.default.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  publicly_accessible     = false
  skip_final_snapshot     = var.skip_final_snapshot
  deletion_protection     = var.deletion_protection
  backup_retention_period = 7
  kms_key_id              = var.kms_key_id

  tags = merge({ Name = "${var.project_name}-payroll-db" }, var.tags)
}
