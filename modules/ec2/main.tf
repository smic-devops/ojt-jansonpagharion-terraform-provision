resource "aws_security_group" "ec2_sg" {
  name   = "ojt-jansonpagharion-ec2-sg"
  vpc_id = var.vpc_id

  tags = {
    Environment = "sandbox"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http_from_alb" {
  security_group_id = aws_security_group.ec2_sg.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "all_out" {
  security_group_id = aws_security_group.ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "this" {
  count         = 2
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.private_subnet_ids[count.index]

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name        = "ojt-jansonpagharion-ec2-${count.index + 1}"
    Environment = "sandbox"
  }
}