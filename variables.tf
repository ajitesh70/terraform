variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/24"
}
 
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "OTMS-vpc"
}
