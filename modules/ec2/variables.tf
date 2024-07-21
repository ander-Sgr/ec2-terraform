variable "ami_options" {
  description = "List of AMI IDs aviable by default"
  type        = map(string)
  default     = {
    "ubuntu_server_22" = "ami-0a0e5d9c7acc336f1"
    "amazon_linux"     = "ami-0b72821e2f351e396"
    "debian_12"        = "ami-00402f0bdf4996822"
  }
}

variable "ami_key" {
  description = "The key AMI to use (ubuntu_server_22, amazon_linux, debian_12)"
  type        = string

  validation {
    condition     = contains(keys(var.ami_options), var.ami_key)
    error_message = "The AMI should the following systems ${join(", ", keys(var.ami_options))}"
  }
}

variable "key_pair" {
    description = "Name of the SSH key pair to use fot the instnace"
    type        = string 
}

variable "instance_type" {
  description = "Type instance EC2"
  type = string
  default = "t2.micro"

  validation {
    condition     = var.instance_type == "t2.micro"
    error_message = "The instance type should be in the free tier"
  }
}

variable "instance_name" {
  type = string
  default = "ec2_server_web"
}