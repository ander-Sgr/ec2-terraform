resource "aws_lb" "main_alb" {
  name               = var.elb_name
  load_balancer_type = var.load_balancer_type
  internal           = var.is_internal
  security_groups    = var.security_groups
  subnets            = var.subnet 
}

resource "aws_alb_target_group" "default_aws_alb_target_group" {
  name     = "${var.ec2_instance_name}-tg" 
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id 

  health_check {
    path                = var.health_check.path
    port                = "traffic-port"
    interval            = var.health_check.interval
    timeout             = var.health_check.timeout
    healthy_threshold   = var.health_check.healthy_threshold
    unhealthy_threshold = var.health_check.unhealthy_threshold
    matcher = "200"
  }

}

resource "aws_autoscaling_attachment" "asg_attchment_bar" {
  autoscaling_group_name = var.asg_name
  lb_target_group_arn = aws_alb_target_group.default_aws_alb_target_group.arn
}

resource "aws_alb_listener" "ec2_http_listener" {
  load_balancer_arn = aws_lb.main_alb.id
  port = "8080"
  protocol = "HTTP"
  depends_on = [ aws_alb_target_group.default_aws_alb_target_group ]

  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.default_aws_alb_target_group.arn
  }
}