output "elb_dns" {
  description = "DNS to reach instances"
  value       = module.asg.elb_dns
}

output "asg_name" {
  description = "Name of Auto_Scaling Group"
  value       = module.asg.asg_name
}

output "target_group_arn" {
  description = "ARN of target group"
  value       = module.asg.target_group_arn
}