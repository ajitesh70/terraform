provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "otms-dev-state7864582"
    key            = "env/dev/application/otms/acm/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}

# ─────────────────────────────────────────
# REMOTE STATE — ROUTE53
# Zone ID aur Zone Name fetch karo
# ─────────────────────────────────────────
data "terraform_remote_state" "route53" {
  backend = "s3"

  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/otms/route53/terraform.tfstate"
    region = "us-east-1"
  }
}

# ─────────────────────────────────────────
# ACM SSL CERTIFICATE
# DNS Validation method
# ─────────────────────────────────────────
resource "aws_acm_certificate" "ssl_cert" {
  domain_name               = data.terraform_remote_state.route53.outputs.zone_name
  validation_method         = "DNS"
  subject_alternative_names = var.subject_alternative_names

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.project}-${var.env}-ssl-cert"
    Environment = var.env
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# ─────────────────────────────────────────
# ROUTE53 — DNS Validation CNAME Records
# ACM jo CNAME records maange wo
# Route53 mein automatically create honge
# ─────────────────────────────────────────
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.ssl_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.terraform_remote_state.route53.outputs.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

# ─────────────────────────────────────────
# ACM CERTIFICATE VALIDATION
# Wait karta hai jab tak ISSUED na ho
# ─────────────────────────────────────────
resource "aws_acm_certificate_validation" "ssl_cert_validation" {
  certificate_arn         = aws_acm_certificate.ssl_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
