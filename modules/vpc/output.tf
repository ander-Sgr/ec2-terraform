output "vpc_id" {
    description = "The ID of the VPC"
    value = aws_vpc.my_vpc.id
}

output "internet_gateway_id" {
  description = "The ID of the internet gateway "
  value       = aws_internet_gateway.internet_gateway.id
}

output "nat_private_gateway_id" {
  value = aws_nat_gateway.nat_private_gateway.id
}