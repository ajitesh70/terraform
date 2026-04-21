variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}
 
variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "otms-dev-key"
}
