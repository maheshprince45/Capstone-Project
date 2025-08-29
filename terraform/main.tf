terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" { region = var.region }

locals {
  tags = { Project = var.project, Owner = "devops" }
}

# VPC + IGW + Subnet + RT
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(local.tags, { Name = "${var.project}-vpc" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.tags, { Name = "${var.project}-igw" })
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  tags = merge(local.tags, { Name = "${var.project}-public-subnet" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(local.tags, { Name = "${var.project}-public-rt" })
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security group: SSH + Web + K8s API + NodePort range
resource "aws_security_group" "sg" {
  name        = "${var.project}-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow SSH/HTTP/HTTPS/K8s"

  ingress { 
    from_port=22   
    to_port=22   
    protocol="tcp" 
    cidr_blocks=[var.allowed_ssh_cidr] 
    }
  ingress { 
    from_port=80   
    to_port=80   
    protocol="tcp" 
    cidr_blocks=["0.0.0.0/0"] 
    }
  ingress { 
    from_port=443  
    to_port=443  
    protocol="tcp" 
    cidr_blocks=["0.0.0.0/0"] 
    }
  ingress { 
    from_port=6443 
    to_port=6443 
    protocol="tcp" 
    cidr_blocks=["0.0.0.0/0"] 
    }       
  ingress { 
    from_port=30000 
    to_port=32767 
    protocol="tcp" 
    cidr_blocks=["0.0.0.0/0"] 
    }     # NodePort

  egress  { 
    from_port=0 
    to_port=0 
    protocol="-1" 
    cidr_blocks=["0.0.0.0/0"] 
    }
  tags = merge(local.tags, { Name = "${var.project}-sg" })
}

# SSH key pair (inject your PUBLIC key)
resource "aws_key_pair" "ansible_key" {
  key_name   = var.ssh_key_name
  public_key = file(var.ssh_public_key_path)
  tags       = local.tags
}


resource "aws_instance" "ubuntu_host" {
  ami                         = "ami-0261755bbcb8c4a84"
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  key_name                    = aws_key_pair.ansible_key.key_name
  associate_public_ip_address = true

  tags = merge(local.tags, { Name = "${var.project}-ubuntu-k8s" })
}


