variable "vpc_name" {
  description = "Existing VPC Name"
  type        = string
  default     = "OTMS-vpc"
}
 
variable "public_subnet_name" {
  description = "Public Subnet Name (for NAT)"
  type        = string
  default     = "otms-dev-public-subnet-1a"
}
