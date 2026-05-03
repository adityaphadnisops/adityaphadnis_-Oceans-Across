variable "vpc_id" { type = string }
variable "tenants" { type = list(string) }
variable "admin_cidr" { type = string }

data "aws_vpc" "this" {
  id = var.vpc_id
}

resource "aws_security_group" "tenant" {
  for_each = toset(var.tenants)
  name        = "tenant-${each.key}-sg"
  description = "Tenant ${each.key} EC2 security group"
  vpc_id      = var.vpc_id

  # Allow intra-tenant traffic only (self) and block other tenants by default.
  ingress {
    description = "Allow from same tenant"
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self = true
  }

  # Allow outbound HTTPS for SSM/Secrets/Updates.
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "tenant-${each.key}-sg" }
}

# Optional SSH ingress from admin CIDR (disabled when admin_cidr is empty)
resource "aws_security_group_rule" "tenant_ssh_admin" {
  count = var.admin_cidr != "" ? length(var.tenants) : 0
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = [var.admin_cidr]
  security_group_id = aws_security_group.tenant[ element(var.tenants, count.index) ].id
  description = "SSH from admin CIDR - only set in emergencies"
}

resource "aws_security_group_rule" "tenant_egress_db" {
  for_each = aws_security_group.tenant
  type = "egress"
  from_port = 5432
  to_port = 5432
  protocol = "tcp"
  security_group_id = each.value.id
  cidr_blocks = [data.aws_vpc.this.cidr_block]
}

resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "RDS SG, allows only tenant app traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = []
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "rds-sg" }
}

resource "aws_security_group_rule" "rds_from_tenant" {
  for_each = aws_security_group.tenant
  type = "ingress"
  from_port = 5432
  to_port = 5432
  protocol = "tcp"
  security_group_id = aws_security_group.rds.id
  source_security_group_id = each.value.id
}
