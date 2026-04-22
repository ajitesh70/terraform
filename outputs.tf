# ─────────────────────────────────────────
# Notification Listener Rule Outputs
# ─────────────────────────────────────────
output "notification_rule_arn" {
  description = "ARN of notification listener rule (Priority 4)"
  value       = aws_lb_listener_rule.notification_rule.arn
}

output "notification_rule_priority" {
  description = "Priority of notification listener rule"
  value       = aws_lb_listener_rule.notification_rule.priority
}
