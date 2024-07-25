output "instance_id" {
    description = "ID of the instance EC2"
    value       = aws_instance.instances.id
}
