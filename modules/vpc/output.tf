output "vpc_id" {
    description = "The ID of the VPC"
    value = aws_vpc.my_vpc.id
}

output "internet_gateway_id" {
  description = "The ID of the internet gateway "
  value       = aws_internet_gateway.internet_gateway.id
}
