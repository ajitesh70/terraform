# ─────────────────────────────────────────
# ALB Outputs
# Referenced by:
#   - Listener branch     (load_balancer_arn)
#   - Target Group branch (alb_arn for association)
# ─────────────────────────────────────────
output "alb_arn" {
  description = "ARN of the Application Load Balancer — used by Listener branch"
  value       = aws_lb.alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB (use this to access the application)"
  value       = aws_lb.alb.dns_name
}

output "alb_zone_id" {
  description = "Hosted Zone ID of the ALB — used for Route53 alias records"
  value       = aws_lb.alb.zone_id
}

output "alb_name" {
  description = "Name of the ALB"
  value       = aws_lb.alb.name
}
