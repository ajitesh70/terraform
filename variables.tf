variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "env" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "otms"
}

variable "ssl_policy" {
  description = "SSL negotiation policy for HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-2016-08"
}
