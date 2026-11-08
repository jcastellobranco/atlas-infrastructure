data "aws_availability_zones" "available" { state = "available" }
data "aws_ssm_parameter" "al2023" { name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64" }
resource "aws_vpc" "demo" {
  cidr_block = "10.91.0.0/24"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = { Name = "atlas-demo" }
}
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.demo.id
  cidr_block = "10.91.0.0/25"
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
}
resource "aws_internet_gateway" "demo" { vpc_id = aws_vpc.demo.id }
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.demo.id
  route { cidr_block = "0.0.0.0/0"; gateway_id = aws_internet_gateway.demo.id }
}
resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
resource "aws_security_group" "demo" {
  name_prefix = "atlas-demo-"
  vpc_id = aws_vpc.demo.id
  ingress { description = "Restricted demo web access"; from_port = 8080; to_port = 8080; protocol = "tcp"; cidr_blocks = [var.allowed_http_cidr] }
  egress { from_port = 0; to_port = 0; protocol = "-1"; cidr_blocks = ["0.0.0.0/0"] }
  lifecycle { create_before_destroy = true }
}
resource "aws_iam_role" "ssm" {
  name = "atlas-demo-ssm"
  assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" }, Action = "sts:AssumeRole" }] })
}
resource "aws_iam_role_policy_attachment" "ssm" {
  role = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_instance_profile" "demo" {
  name = "atlas-demo-ssm"
  role = aws_iam_role.ssm.name
}
resource "aws_instance" "demo" {
  ami = data.aws_ssm_parameter.al2023.value
  instance_type = var.instance_type
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.demo.id]
  iam_instance_profile = aws_iam_instance_profile.demo.name
  associate_public_ip_address = true
  metadata_options { http_tokens = "required" }
  root_block_device { volume_size = 30; volume_type = "gp3"; encrypted = true }
  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail
    dnf update -y
    dnf install -y docker git
    systemctl enable --now docker
    mkdir -p /opt/atlas
    chown ec2-user:ec2-user /opt/atlas
  EOF
  tags = { Name = "atlas-demo" }
}
