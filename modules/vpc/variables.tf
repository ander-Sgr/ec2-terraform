variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC created"
  type        = string
}

variable "subnet_public_id" {
  description = "The subnet ID "
  type        = string
}

variable "private_ip_aws_eip" {
  type = string
}