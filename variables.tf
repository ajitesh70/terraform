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

variable "scale_out_cpu_threshold" {
  description = "CPU % threshold to trigger scale out (add instance)"
  type        = number
  default     = 70
}

variable "scale_in_cpu_threshold" {
  description = "CPU % threshold to trigger scale in (remove instance)"
  type        = number
  default     = 30
}
