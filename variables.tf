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

variable "domain_name" {
  description = "Primary domain name for hosted zone (e.g. otms.yourdomain.com)"
  type        = string
  default     = "innovitisolutions.in"
}
