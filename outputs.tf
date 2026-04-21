# ─────────────────────────────────────────
# Target Group Outputs
# Referenced by:
#   - Listener Rule branch (target_group_arn)
#   - Listener branch      (default_action target_group_arn)
# ─────────────────────────────────────────
output "frontend_tg_arn" {
  description = "ARN of the Frontend Target Group — used by Listener / Listener Rule branch"
  value       = aws_lb_target_group.frontend_tg.arn
}

output "frontend_tg_name" {
  description = "Name of the Frontend Target Group"
  value       = aws_lb_target_group.frontend_tg.name
}

output "frontend_tg_port" {
  description = "Port on which the Target Group forwards traffic (3000)"
  value       = aws_lb_target_group.frontend_tg.port
}
