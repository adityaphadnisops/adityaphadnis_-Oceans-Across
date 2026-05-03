variable "name" { type = string }
variable "cidr" { type = string }
variable "azs" { type = list(string) }
variable "public_subnet_cidrs" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }

resource "aws_vpc" "this" {
  cidr_block = var.cidr
  tags = merge({ Name = var.name }, var.tags)
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = merge({ Name = "${var.name}-igw" }, var.tags)
}

resource "aws_subnet" "public" {
  for_each = { for idx, cidr in var.public_subnet_cidrs : idx => cidr }
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = element(var.azs, each.key)
  map_public_ip_on_launch = true
  tags = merge({ Name = "${var.name}-public-${each.key}" }, var.tags)
}

resource "aws_subnet" "private" {
  for_each = { for idx, cidr in var.private_subnet_cidrs : idx => cidr }
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = element(var.azs, each.key)
  map_public_ip_on_launch = false
  tags = merge({ Name = "${var.name}-private-${each.key}" }, var.tags)
}

resource "aws_eip" "nat" {
  for_each = aws_subnet.public
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  for_each = aws_subnet.public
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id
  tags = merge({ Name = "${var.name}-nat-${each.key}" }, var.tags)
}

# Network ACLs for additional network-level controls (stateless)
resource "aws_network_acl" "public_nacl" {
  vpc_id = aws_vpc.this.id
  tags = merge({ Name = "${var.name}-public-nacl" }, var.tags)
}

resource "aws_network_acl" "private_nacl" {
  vpc_id = aws_vpc.this.id
  tags = merge({ Name = "${var.name}-private-nacl" }, var.tags)
}

resource "aws_network_acl_rule" "public_inbound_allow_https" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "6"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "private_outbound_allow_https" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 100
  egress         = true
  protocol       = "6"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge({ Name = "${var.name}-public-rt" }, var.tags)
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public
  subnet_id = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags = merge({ Name = "${var.name}-private-rt" }, var.tags)
}

resource "aws_route" "private_nat" {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat[element(keys(aws_nat_gateway.nat), 0)].id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private
  subnet_id = each.value.id
  route_table_id = aws_route_table.private.id
}

# associate NACLs to subnets: public -> public_nacl, private -> private_nacl
resource "aws_network_acl_association" "public_assoc" {
  for_each = aws_subnet.public
  network_acl_id = aws_network_acl.public_nacl.id
  subnet_id = each.value.id
}

resource "aws_network_acl_association" "private_assoc" {
  for_each = aws_subnet.private
  network_acl_id = aws_network_acl.private_nacl.id
  subnet_id = each.value.id
}

# VPC Endpoints to keep traffic to AWS control plane inside the AWS network (recommended for security)
data "aws_region" "current" {}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id = aws_vpc.this.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids = [for s in aws_subnet.private : s.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id = aws_vpc.this.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids = [for s in aws_subnet.private : s.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2_messages" {
  vpc_id = aws_vpc.this.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids = [for s in aws_subnet.private : s.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id = aws_vpc.this.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  vpc_endpoint_type = "Interface"
  subnet_ids = [for s in aws_subnet.private : s.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id = aws_vpc.this.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type = "Interface"
  subnet_ids = [for s in aws_subnet.private : s.id]
  private_dns_enabled = true
}

# S3 Gateway endpoint: routes to private route table(s) so S3 traffic stays inside AWS network
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = merge({ Name = "${var.name}-s3-gateway-endpoint" }, var.tags)
}
