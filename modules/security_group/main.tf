resource "aws_security_group" "http_and_ssh_access" {
  name_prefix = var.name_secgroup

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port     = ingress.value.from_port
      to_port       = ingress.value.to_port
      protocol      = ingress.value.protocol
      cidr_blocks   = ingress.value.cidr_blocks 
    }
  }
  
  dynamic "egress" {
    for_each = var.egress_rules
    content {
      from_port     = egress-value.from_port
      to_port       = egress.value.to_port
      protocol      = egress.value.protocol
      cidr_blocks   = egress.value.cidr_blocks
    }
  }

  tags = {
    Name = var.name_secgroup
  }
}
