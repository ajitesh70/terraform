provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "otms-dev-state7864582"
    key            = "env/dev/application/otms/route53/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}

# ─────────────────────────────────────────
# REMOTE STATE — ALB
# ALB DNS name aur Zone ID chahiye
# Route53 alias record ke liye
# ─────────────────────────────────────────
data "terraform_remote_state" "alb" {
  backend = "s3"

  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/otms/alb/terraform.tfstate"
    region = "us-east-1"
  }
}

# ─────────────────────────────────────────
# ROUTE53 — Public Hosted Zone
# Agar already exist karta hai toh
# import kar lo:
# terraform import aws_route53_zone.main <ZONE_ID>
# ─────────────────────────────────────────
resource "aws_route53_zone" "main" {
  name    = var.domain_name
  comment = "Hosted zone for ${var.project} - ${var.env}"

  tags = {
    Name        = "${var.project}-${var.env}-hosted-zone"
    Environment = var.env
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# ─────────────────────────────────────────
# ROUTE53 — A Record (Alias)
# Domain → ALB DNS name
# e.g. otms.yourdomain.com → ALB
# ─────────────────────────────────────────
resource "aws_route53_record" "alb_alias" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.alb.outputs.alb_dns_name
    zone_id                = data.terraform_remote_state.alb.outputs.alb_zone_id
    evaluate_target_health = true
  }
}
