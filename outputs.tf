# ─────────────────────────────────────────
# ASG Outputs
# Referenced by:
#   - ASG Policies branch (autoscaling_group_name)
# ─────────────────────────────────────────
output "asg_name" {
  description = "Name of the Auto Scaling Group — used by ASG Policies branch"
  value       = aws_autoscaling_group.frontend_asg.name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.frontend_asg.arn
}

output "asg_min_size" {
  description = "Minimum size of the ASG"
  value       = aws_autoscaling_group.frontend_asg.min_size
}

output "asg_max_size" {
  description = "Maximum size of the ASG"
  value       = aws_autoscaling_group.frontend_asg.max_size
}

output "asg_desired_capacity" {
  description = "Desired capacity of the ASG"
  value       = aws_autoscaling_group.frontend_asg.desired_capacity
}
