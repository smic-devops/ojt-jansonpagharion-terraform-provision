### AI GENERATED

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  type    = string
  default = "ap-southeast-1"
}

# --- VPC via Registry Module (example) ---
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "demo-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = false
}

# --- Security Group you fully control ---
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP(80) and HTTPS(443)"
  vpc_id      = module.vpc.vpc_id
  tags = { Name = "web-sg" }
}

# Allow inbound 80 from anywhere
resource "aws_vpc_security_group_ingress_rule" "http_in" {
  security_group_id = aws_security_group.web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# Allow inbound 443 from anywhere
resource "aws_vpc_security_group_ingress_rule" "https_in" {
  security_group_id = aws_security_group.web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# Egress all (typical)
resource "aws_vpc_security_group_egress_rule" "all_out" {
  security_group_id = aws_security_group.web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# --- EC2 via Registry Module ---
module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  name                        = "demo-ec2"
  ami                         = var.ami_id         # pass a valid AMI for your region
  instance_type               = "t3.micro"
  subnet_id                   = module.vpc.private_subnets[0] # or public_subnets[0] if you want a public instance
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = false

  # Optional: simple web page to test 80/443 (you still need a web server for 443/TLS config)
  user_data = <<-EOT
              #!/bin/bash
              (command -v yum >/dev/null && sudo yum install -y httpd && echo OK > /var/www/html/index.html && sudo systemctl enable --now httpd) \
              || (sudo apt-get update -y && sudo apt-get install -y apache2 -y && echo OK | sudo tee /var/www/html/index.html && sudo systemctl enable --now apache2)
              EOT
}

variable "ami_id" {
  description = "AMI to use for EC2 (e.g., Amazon Linux 2/Ubuntu for your region)"
  type        = string
}
