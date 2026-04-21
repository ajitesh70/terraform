# ─────────────────────────────────────────
# Route53 Outputs
# Referenced by:
#   - ACM branch (hosted_zone_name variable)
# ─────────────────────────────────────────
output "zone_id" {
  description = "Route53 Hosted Zone ID — used by ACM for DNS validation"
  value       = aws_route53_zone.main.zone_id
}

output "zone_name" {
  description = "Route53 Hosted Zone domain name"
  value       = aws_route53_zone.main.name
}

output "name_servers" {
  description = "NS records — copy these to your domain registrar (GoDaddy/Namecheap etc.)"
  value       = aws_route53_zone.main.name_servers
}

output "alb_alias_fqdn" {
  description = "Fully qualified domain name of the ALB alias record"
  value       = aws_route53_record.alb_alias.fqdn
}
