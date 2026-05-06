variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "env" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "otms"
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
  default     = "ami-017282e4f588af446"
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t3.small"
}
