provider "aws" {
  region = var.region
}

# for azs
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = var.vpc
  tags   = { Name = "main-igw" }
}

####### Public table & routes

resource "aws_route_table" "public" {
  vpc_id = var.vpc
  tags   = { Name = "rt-public" }
}

resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = var.subnetpublic1
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = var.subnetpublic2
  route_table_id = aws_route_table.public.id
}

## Private table & routes

resource "aws_route_table" "private" {
  vpc_id = var.vpc
  tags   = { Name = "rt-private" }
}

resource "aws_route" "private_default" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = var.subnetprivate
  route_table_id = aws_route_table.private.id
}

## NAT Gateway and EIP for Private Subnet Internet Access

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags   = { Name = "nat-eip" }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = var.subnetpublic1
  tags          = { Name = "nat-gw" }
}

############## ALB & SG

resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "ALB SG"
  vpc_id      = var.vpc
  tags        = { Name = "alb_sg" }
}

# Internet to ALB
resource "aws_vpc_security_group_ingress_rule" "alb_http_in" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}
resource "aws_vpc_security_group_ingress_rule" "alb_https_in" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id            = aws_security_group.alb_sg.id
  referenced_security_group_id = aws_security_group.ec2_sg.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [var.subnetpublic1, var.subnetpublic2]
}

# Target group
resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc

  health_check {
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.test.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

########### EC2 Instance & SG

resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "EC2 app SG"
  vpc_id      = var.vpc
  tags        = { Name = "ec2_sg" }
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.ec2_sg.id
  referenced_security_group_id = aws_security_group.alb_sg.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ec2_egress_all" {
  security_group_id = aws_security_group.ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "web" {
  ami                         = var.ami_type
  instance_type               = var.instance_type
  subnet_id                   = var.subnetprivate
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]

}

resource "aws_lb_target_group_attachment" "app_attach" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.web.id
  port             = 80
}
