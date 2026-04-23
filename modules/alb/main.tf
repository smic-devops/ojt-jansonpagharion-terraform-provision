resource "aws_security_group" "alb_sg" {
  name   = "ojt-jansonpagharion-alb-sg"
  vpc_id = var.vpc_id

  tags = {
    Environment = "sandbox"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http_in" {
  security_group_id = aws_security_group.alb_sg.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_lb" "this" {
  name               = "app-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "this" {
  name     = "ojt-jansonpagharion-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  tags = {
    Name        = "ojt-jansonpagharion-listener-http"
    Environment = "sandbox"
  }
}

resource "aws_lb_target_group_attachment" "attach" {
  for_each = toset(var.instance_ids)

  target_group_arn = aws_lb_target_group.this.arn
  target_id        = each.value
  port             = 80
}