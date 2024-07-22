output "public_subnet_ids" {
  description = "ID's of the public subnet"
  
  value = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = var.internet_gateway_id
}

output "nat_private_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = var.nat_private_gateway_id 
}