
# for azs
data "aws_availability_zones" "available" {
  state = "available"
}

############## ALB & SG

resource "aws_security_group" "alb_security_group" {
  name        = "itss_ojt_pagharion_alb_security_group"
  description = "ALB SG"
  vpc_id      = var.vpc

  tags = {
    Name        = "itss_ojt_pagharion_alb_security_group"
    Environment = "Sandbox"
  }
}

# Internet to ALB
resource "aws_vpc_security_group_ingress_rule" "alb_http_in" {
  security_group_id = aws_security_group.alb_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}
resource "aws_vpc_security_group_ingress_rule" "alb_https_in" {
  security_group_id = aws_security_group.alb_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id            = aws_security_group.alb_security_group.id
  referenced_security_group_id = aws_security_group.ec2_security_group.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_lb" "alb" {
  name               = "itss_ojt_pagharion_load_balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_security_group.id]
  subnets            = [var.subnetpublic1, var.subnetpublic2]
}

# Target group
resource "aws_lb_target_group" "app_target_group" {
  name     = "itss_ojt_pagharion_target_group"
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
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}

########### EC2 Instance & SG

resource "aws_security_group" "ec2_security_group" {
  name        = "itss_ojt_pagharion_ec2_security_group"
  description = "EC2 app SG"
  vpc_id      = var.vpc
  tags        = { Name = "itss_ojt_pagharion_ec2_security_group" }
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.ec2_security_group.id
  referenced_security_group_id = aws_security_group.alb_security_group.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ec2_egress_all" {
  security_group_id = aws_security_group.ec2_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "web" {
  ami                         = var.ami_type
  instance_type               = var.instance_type
  subnet_id                   = var.subnetprivate
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.ec2_security_group.id]

  tags = {
    Name           = "itss-ojt-Pagharion-ec2"
    Environment    = "Sandbox"
    backup         = "no"
    Schedule       = "running"
    Patch          = "No"
    Resource_Types = "Instances Volumes Network_Interfaces"
  }
}

resource "aws_lb_target_group_attachment" "app_attach" {
  target_group_arn = aws_lb_target_group.app_target_group.arn
  target_id        = aws_instance.web.id
  port             = 80
}
