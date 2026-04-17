variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
  default     = "otms-dev-state"
}

variable "dynamodb_table" {
  description = "DynamoDB table for state locking"
  type        = string
  default     = "terraform-lock"
}
