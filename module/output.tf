output "elb_dns" {
  description = "DNS to reach instances"
  value       = aws_lb.web_lb.dns_name
}

output "asg_name" {
  description = "Name of Auto_Scaling Group"
  value       = aws_autoscaling_group.web_server_asg.name
}

output "target_group_arn" {
  description = "ARN of target group"
  value       = aws_lb_target_group.asg_lg_tg.arn
}