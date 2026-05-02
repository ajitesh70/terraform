provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "otms-dev-state7864582"
    key            = "env/dev/application/otms/notification-listener-rule/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}

# ─────────────────────────────────────────
# REMOTE STATE — LISTENER
# HTTPS:443 listener ARN
# ─────────────────────────────────────────
data "terraform_remote_state" "listener" {
  backend = "s3"

  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/otms/listener/terraform.tfstate"
    region = "us-east-1"
  }
}

# ─────────────────────────────────────────
# REMOTE STATE — NOTIFICATION TARGET GROUP
# ─────────────────────────────────────────
data "terraform_remote_state" "tg_notification" {
  backend = "s3"

  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/otms/tg-notification/terraform.tfstate"
    region = "us-east-1"
  }
}

# ─────────────────────────────────────────
# LISTENER RULE — Priority 4
# Path : /api/v1/notification/*
# TG   : notification-tg (port 5000)
# ─────────────────────────────────────────
resource "aws_lb_listener_rule" "notification_rule" {
  listener_arn = data.terraform_remote_state.listener.outputs.http_listener_arn
  priority     = 4

  condition {
    path_pattern {
      values = ["/api/v1/notification/*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = data.terraform_remote_state.tg_notification.outputs.notification_tg_arn
  }

  tags = {
    Name        = "${var.project}-${var.env}-notification-listener-rule"
    Environment = var.env
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}
