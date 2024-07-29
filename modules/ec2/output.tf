output "instance_id" {
    description = "ID of the instance EC2"
    value       = aws_instance.instances.id
}

output "selected_ami_id_bastion" {
  value = local.selected_ami_id
}

output "bastion_ip" {
  value = aws_instance.instances.public_ip
}