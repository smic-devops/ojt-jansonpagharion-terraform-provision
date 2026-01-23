# 1) Fetch your public IP as plain text
data "http" "my_ip" {
  url = "https://checkip.amazonaws.com/"
 
  request_headers = {
    Accept = "text/plain"
  }
}
 
# 2) Build a clean /32 CIDR
locals {
  my_ip       = trimspace(data.http.my_ip.response_body) # removes newline/whitespace
  my_ip_cidr  = "${local.my_ip}/32"
}
 
# Create a VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "ojt-main-vpc" }
}
 
# Create a private subnet
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"  
 
  tags = {
    Name = "ojt-private-subnet"
  }
}
 
# Create a route table for the private subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
 
  tags = {
    Name = "ojt-private-rt"
  }
}
 
# Associate the route table with the private subnet
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
 
# Create an EC2 instance in the private subnet
resource "aws_instance" "web" {
  ami                    = "ami-0ba8d27d35e9915fb"
  instance_type          = "t3.micro"
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = false
}
 
# Create a security group allowing HTTP/HTTPS from caller IP only
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-web-from-my-ip"
  description = "Allow HTTP/HTTPS from caller IP only"
  vpc_id      = aws_vpc.main.id
}
 
# Create ingress rules for HTTP and HTTPS from caller IP
resource "aws_vpc_security_group_ingress_rule" "http_from_my_ip" {
  security_group_id = aws_security_group.ec2_sg.id
  description       = "HTTP from my IP"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = local.my_ip_cidr
}
 
resource "aws_vpc_security_group_ingress_rule" "https_from_my_ip" {
  security_group_id = aws_security_group.ec2_sg.id
  description       = "HTTPS from my IP"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = local.my_ip_cidr
}
 
resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.ec2_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "All outbound"
}