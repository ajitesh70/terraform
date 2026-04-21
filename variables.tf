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
 
variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}
