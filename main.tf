provider "aws" {
  region = var.aws_region
}
 
terraform {
  backend "s3" {
    bucket         = "otms-dev-state7864582"
    key            = "env/dev/application/network/sshkey/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}
 
# Generate RSA Private Key
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
 
# Create AWS Key Pair using generated public key
resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.ssh_key.public_key_openssh
 
  tags = {
    Name        = var.key_name
    Environment = "dev"
    Project     = "OTMS"
    ManagedBy   = "Terraform"
  }
}
 
# Save private key locally
resource "local_file" "private_key_pem" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${var.key_name}.pem"
  file_permission = "0400"
}
