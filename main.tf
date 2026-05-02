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
# REMOTE STATE — FRONTEND TARGET GROUP
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
# LISTENER — HTTP:80
# No ACM needed — HTTP only
# Default action → frontend TG
# ─────────────────────────────────────────
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = data.terraform_remote_state.alb.outputs.alb_arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = data.terraform_remote_state.tg_frontend.outputs.frontend_tg_arn
  }

  tags = {
    Name        = "${var.project}-${var.env}-http-listener"
    Environment = var.env
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}
