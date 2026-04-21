# ─────────────────────────────────────────
# ACM Outputs
# Referenced by:
#   - Listener branch (certificate_arn)
# ─────────────────────────────────────────
output "certificate_arn" {
  description = "ACM Certificate ARN — use in Listener branch"
  value       = aws_acm_certificate_validation.ssl_cert_validation.certificate_arn
}

output "certificate_domain" {
  description = "Primary domain name of the certificate"
  value       = aws_acm_certificate.ssl_cert.domain_name
}

output "certificate_status" {
  description = "Status of the ACM certificate (should be ISSUED)"
  value       = aws_acm_certificate.ssl_cert.status
}
