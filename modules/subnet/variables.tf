variable "vpc_id" {
  description = "The ID of the VPC for associate the subnet"
  type        = string
}

variable "cidr_block" {
  description = "The CIDR block for the subnet"
  type        = string 
}

variable "availability_zones" {
    description = "availability_zones for the subnet"
    type        = list(string)
    default     = [ "us-east-1", "us-west-2" ]
}

variable "internet_gateway_id" {
  description = "The ID of the internet Gateway"
  type        = string
}

variable "map_public_ip_on_lunch" {
  description = "Should be true if instances in the subnet should be assigned a public IP address"
  type        = bool 
}

variable "name" {
    description = "Name of a resource"
    type        = string
}

variable "nat_private_gateway_id" {
  description = "The ID of the nat private gateway created"
  type        = string
}