# ─────────────────────────────────────────
# Notification Instance Outputs
# Referenced by:
#   - notification-tg branch (target attachment)
# ─────────────────────────────────────────
output "instance_id" {
  description = "Notification EC2 Instance ID — used by notification-tg branch"
  value       = aws_instance.notification_instance.id
}

output "private_ip" {
  description = "Private IP of Notification EC2 Instance"
  value       = aws_instance.notification_instance.private_ip
}

output "ssh_note" {
  description = "Reminder: use Bastion or SSM to connect"
  value       = "Use Bastion or SSM to connect — No Public IP assigned"
}
