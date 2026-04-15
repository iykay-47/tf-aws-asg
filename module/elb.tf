# 
resource "aws_lb" "web_lb" {
  name               = "${var.cluster_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb.id]
  subnets            = data.aws_subnets.default.ids
  # enable_deletion_protection = 

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "asg_lg_tg" {
  name     = "${var.cluster_name}-asg-tg"
  port     = var.server_port # Port 8080 where Apache is running
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }
}

# Load Balancer Listener - Listens for incoming requests on port 80
resource "aws_lb_listener" "asg" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = local.http_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg_lg_tg.arn
  }
}