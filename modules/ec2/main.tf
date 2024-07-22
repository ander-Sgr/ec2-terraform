locals {
  selected_ami_id = var.ami_options[var.ami_key]
}

resource "aws_instance" "app_server" {
    ami             = local.selected_ami_id
    instance_type   = var.instance_type
    key_name        = var.key_pair 

    tags = {
      Name = var.instance_name
    }
}