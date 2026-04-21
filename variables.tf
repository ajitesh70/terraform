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

variable "ami_id" {
  description = "AMI ID for Notification EC2 instance"
  type        = string
  default     = "ami-0b73ce37f347c345b"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}
