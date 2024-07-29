output "elb_name" {
  value = var.elb_name
}

output "target_group_arn" {
  value = aws_alb_target_group.default_aws_alb_target_group.arn
}

output "alb_dns_name" {
  value = aws_lb.main_alb.dns_name
}