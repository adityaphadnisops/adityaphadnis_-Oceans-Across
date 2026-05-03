variable "name" { type = string }
variable "ami_filter" { type = map(string) }
variable "instance_type" { type = string }
variable "subnet_id" { type = string }
variable "security_group_ids" { type = list(string) }
variable "iam_instance_profile" { type = string | null }

data "aws_ami" "chosen" {
  most_recent = true
  filter {
    name   = "name"
    values = [var.ami_filter.name]
  }
  owners = ["137112412989"] # Amazon
}

resource "aws_instance" "this" {
  ami           = data.aws_ami.chosen.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  # Ensure instances do NOT get public IPs (private subnet only) and use instance profile for SSM access
  associate_public_ip_address = false
  iam_instance_profile = var.iam_instance_profile

  tags = merge({ Name = "${var.name}-instance", Tenant = var.name }, var.tags)
}
