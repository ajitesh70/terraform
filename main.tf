provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "otms-dev-state7864582"
    key            = "env/dev/application/otms/listener/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}

# ─────────────────────────────────────────
# REMOTE STATE — ALB
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
# REMOTE STATE — ACM CERTIFICATE
# ─────────────────────────────────────────
data "terraform_remote_state" "acm" {
  backend = "s3"

  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/otms/acm/terraform.tfstate"
    region = "us-east-1"
  }
}

# ─────────────────────────────────────────
# REMOTE STATE — tg-frontend
# ─────────────────────────────────────────
data "terraform_remote_state" "tg_frontend" {
  backend = "s3"

  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/otms/target-group/terraform.tfstate"
    region = "us-east-1"
  }
}

# ─────────────────────────────────────────
# LISTENER — HTTPS:443
# Default action → tg-frontend only
# (Baaki rules baad mein alag branch mein)
# ─────────────────────────────────────────
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = data.terraform_remote_state.alb.outputs.alb_arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = data.terraform_remote_state.acm.outputs.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = data.terraform_remote_state.tg_frontend.outputs.frontend_tg_arn
  }

  tags = {
    Name        = "${var.project}-${var.env}-https-listener"
    Environment = var.env
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}
