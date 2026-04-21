# ─────────────────────────────────────────
# Notification Launch Template Outputs
# Referenced by:
#   - Notification ASG branch
# ─────────────────────────────────────────
output "launch_template_id" {
  description = "Notification Launch Template ID — used by Notification ASG branch"
  value       = aws_launch_template.notification_template.id
}

output "launch_template_latest_version" {
  description = "Latest version of Notification Launch Template"
  value       = aws_launch_template.notification_template.latest_version
}

output "launch_template_name" {
  description = "Name of Notification Launch Template"
  value       = aws_launch_template.notification_template.name
}
