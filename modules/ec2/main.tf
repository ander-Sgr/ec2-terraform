locals {
  selected_ami_id = var.ami_options[var.ami_key]
}

resource "aws_instance" "instances" {
    ami             = local.selected_ami_id
    instance_type   = var.instance_type
    security_groups = var.security_groups
    subnet_id       = var.subnet_id 
    user_data       = var.user_data
    key_name        = var.key_pair

    tags = {
      Name = var.instance_name
    }
}