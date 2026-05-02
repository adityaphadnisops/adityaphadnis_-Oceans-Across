data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

resource "aws_security_group" "tenant" {
  for_each = toset(var.tenant_names)

  name        = "${var.project_name}-${each.key}-sg"
  description = "Tenant security group for ${each.key} backend services"
  vpc_id      = var.vpc_id

  tags = {
    Name   = "${var.project_name}-${each.key}-sg"
    Tenant = each.key
  }
}

resource "aws_security_group_rule" "self_ingress_ssh" {
  for_each = aws_security_group.tenant

  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = each.value.id
  self              = true
}

resource "aws_security_group_rule" "self_ingress_app" {
  for_each = aws_security_group.tenant

  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = each.value.id
  self              = true
}

resource "aws_security_group_rule" "all_egress" {
  for_each = aws_security_group.tenant

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = each.value.id
}

resource "aws_instance" "tenant" {
  count                       = length(var.tenant_names)
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
  iam_instance_profile        = var.instance_profile_names[count.index]
  vpc_security_group_ids      = [aws_security_group.tenant[var.tenant_names[count.index]].id]
  associate_public_ip_address = false

  tags = {
    Name   = "${var.project_name}-${var.tenant_names[count.index]}-backend"
    Tenant = var.tenant_names[count.index]
    Role   = "backend"
  }
}
