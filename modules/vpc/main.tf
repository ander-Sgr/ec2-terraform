resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr_block
  
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name ="${var.vpc_name}-igw"
  }
}

output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.internet_gateway.id
}