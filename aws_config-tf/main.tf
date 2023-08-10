### region ###
provider "aws" {
  region     = "${var.region}"
}

### VPC ###
## VPC-01
resource "aws_vpc" "vpc_01"{
  cidr_block           = "${var.cider_block_a1}"
  enable_dns_hostnames = true   # Enable DNS host
  tags = {
    Name = "vpc_01"
    env = "${var.test_tag}"
  }
}
## Subnet_a_01 in VPC-01
resource "aws_subnet" "sn_a_01"{
  vpc_id            = aws_vpc.vpc_01.id
  cidr_block        = "${var.subnet-a1}"
  availability_zone = "${var.az_a}"
  tags = {
    Name = "sn_a_01"
    env = "${var.test_tag}"
  }
}
## Internet Gateway for ig_a_01
resource "aws_internet_gateway" "ig_a_01"{
  vpc_id            = aws_vpc.vpc_01.id
  tags = {
    Name = "ig_a_01"
    env = "${var.test_tag}"
  }
}
## Route table for vpc01 
resource "aws_route_table" "rt_a_01"{
  vpc_id            = aws_vpc.vpc_01.id
  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.ig_a_01.id
  }
  tags = {
    Name = "rt_a_01"
    env = "${var.test_tag}"
  }
}
## atach Route table on Subnet 
resource "aws_route_table_association" "rt_a_01_associate"{
  subnet_id      = aws_subnet.sn_a_01.id
  route_table_id = aws_route_table.rt_a_01.id
}

## VPC-02
resource "aws_vpc" "vpc_02"{
  cidr_block           = "${var.cider_block_b1}"
  enable_dns_hostnames = true   # Enable DNS host
  tags = {
    Name = "vpc_02"
    env = "${var.test_tag}"
  }
}

# Subnet-b1 in vpc-02
resource "aws_subnet" "sn_b_01" {
  vpc_id            = aws_vpc.vpc_02.id
  cidr_block        = "${var.subnet-b1}"
  availability_zone = "${var.az_a}"
  tags = {
    Name = "sn_b_01"
    env = "${var.test_tag}"
  }
}

# Internet Gateway for ig_b_01
resource "aws_internet_gateway" "ig_b_01" {
  vpc_id            = aws_vpc.vpc_02.id
  tags = {
    Name = "ig_b_01"
    env = "${var.test_tag}"
  }
}

# Route table for vpc-02
resource "aws_route_table" "rt_b_01" {
  vpc_id            = aws_vpc.vpc_02.id
  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.ig_b_01.id
  }
  tags = {
    Name = "rt_b_01"
    env = "${var.test_tag}"
  }
}
# atach Route table on Subnet 
resource "aws_route_table_association" "rt_b_01_associate" {
  subnet_id      = aws_subnet.sn_b_01.id
  route_table_id = aws_route_table.rt_b_01.id
}

### EC2 ###
# Get Amazon Linux 2 AMI latest version 
data "aws_ssm_parameter" "amzn2_latest_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

## instance_01
resource "aws_instance" "instannce_01"{
  ami                         = data.aws_ssm_parameter.amzn2_latest_ami.value
  instance_type               = "t2.micro"
  availability_zone           = "${var.az_a}"
  vpc_security_group_ids      = [aws_security_group.remote_ac01.id]
  subnet_id                   = aws_subnet.sn_a_01.id
  associate_public_ip_address = "true"
  key_name                    = "${var.key_name}"
  tags = {
    Name = "instance_01"
    env = "${var.test_tag}" 
  }
}

## instance_02
resource "aws_instance" "instance_02"{
  ami                         = data.aws_ssm_parameter.amzn2_latest_ami.value
  instance_type               = "t2.micro"
  availability_zone           = "${var.az_a}"
  vpc_security_group_ids      = [aws_security_group.remote_ac02.id]
  subnet_id                   = aws_subnet.sn_b_01.id
  associate_public_ip_address = "true"
  key_name                    = "${var.key_name}"
  tags = {
    Name = "instance_02"
    env = "${var.test_tag}"
  }
}

### Security Group ###
# Get Public IP
data "http" "ifconfig" {
  url = "http://ipv4.icanhazip.com/"
}

variable "allowed_cidr" {
  default = null
}

locals {
  myip         = chomp(data.http.ifconfig.body)
  allowed_cidr = var.allowed_cidr == null ? "${local.myip}/32" : var.allowed_cidr
}

### Create Security Group ###
## Security Group for VPC01
resource "aws_security_group" "remote_ac01" {
  name        = "remote-ac01"
  description = "For EC2 Linux"
  vpc_id      = aws_vpc.vpc_01.id
  tags = {
    Name = "remote_ac01"
  }

  ## Inbound rule
  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.allowed_cidr]
  }
  # ICMP
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [local.allowed_cidr]
  }

  ## Outbound rule
  # all
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
## Security Group for VPC02
resource "aws_security_group" "remote_ac02" {
  name        = "remote-ac02"
  description = "For EC2 Linux"
  vpc_id      = aws_vpc.vpc_02.id
  tags = {
    Name = "remote_ac02"
  }

  ## Inbound rule
  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.allowed_cidr]
  }
  # ICMP
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [local.allowed_cidr]
  }

  ## Outbound rule
  # all
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}