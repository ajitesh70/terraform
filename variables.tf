variable "vpc_name" {
  description = "VPC Name"
  type        = string
  default     = "OTMS-vpc"
}
 
variable "public_subnet_name" {
  description = "Public subnet name prefix"
  type        = string
  default     = "otms-dev-public-subnet"
}
