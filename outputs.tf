# ─────────────────────────────────────────
# notification-tg Outputs
# Referenced by:
#   - Listener Rules branch (notification_tg_arn)
# ─────────────────────────────────────────
output "notification_tg_arn" {
  description = "ARN of notification-tg — used by Listener Rules branch"
  value       = aws_lb_target_group.notification_tg.arn
}

output "notification_tg_name" {
  description = "Name of the target group (notification-tg)"
  value       = aws_lb_target_group.notification_tg.name
}

output "notification_tg_port" {
  description = "Port on which notification-tg forwards traffic (5000)"
  value       = aws_lb_target_group.notification_tg.port
}
