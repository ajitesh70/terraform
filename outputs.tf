# ─────────────────────────────────────────
# Listener Outputs
# Referenced by:
#   - Listener Rules branch (https_listener_arn)
# ─────────────────────────────────────────
output "https_listener_arn" {
  description = "ARN of HTTPS:443 Listener — used by Listener Rules branch"
  value       = aws_lb_listener.https_listener.arn
}
