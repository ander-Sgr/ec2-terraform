resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}

#internet gateway for the public subnet
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name ="${var.vpc_name}-igw"
  }
}

#NAT gateway for the public subnet
resource "aws_eip" "nat_gateway" {
  domain     = "vpc"
  associate_with_private_ip = var.private_ip_aws_eip
  depends_on = [ aws_internet_gateway.internet_gateway ]
  tags  = {
    Name = "nat_gateway"
  }
}

#NAT gateway for private subnets
# (this is for the private subnet to access internet)
resource "aws_nat_gateway" "nat_private_gateway" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = var.subnet_public_id # public subnet
  depends_on    = [ aws_eip.nat_gateway ]

  tags = {
    Name = "NAT for private subnet"
  }
}