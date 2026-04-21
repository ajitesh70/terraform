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

variable "subject_alternative_names" {
  description = "Additional domain names to cover in the certificate"
  type        = list(string)
  default     = ["www.innovitisolutions.in"]

}
