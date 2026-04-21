# ─────────────────────────────────────────
# Notification SG Outputs
# Referenced by:
#   - Notification EC2 / Launch Template branch
#   - notification-tg branch (target attachment)
# ─────────────────────────────────────────
output "notification_sg_id" {
  description = "Notification Security Group ID"
  value       = aws_security_group.notification_sg.id
}

output "notification_sg_name" {
  description = "Notification Security Group Name"
  value       = aws_security_group.notification_sg.name
}

# Alias — consistent naming across modules
output "security_group_id" {
  description = "Alias — Notification Security Group ID"
  value       = aws_security_group.notification_sg.id
}
