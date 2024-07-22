resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.cidr_block
  map_public_ip_on_launch = var.internet_gateway_id
  availability_zone       = element(var.availability_zones, 0)
  
  tags = {
    Name = "${var.name}_subnet_1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.cidr_block
  map_public_ip_on_launch = var.internet_gateway_id
  availability_zone       = element(var.availability_zones, 1)
  
  tags = {
    Name = "${var.name}_subnet_2"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.cidr_block
  map_public_ip_on_launch = var.map_public_ip_on_lunch
  availability_zone       = element(var.availability_zones, 0)

  tags = {
    Name = var.name
  }
}

# route table for the public subnets
resource "aws_route_table" "routing_public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }

  tags = {
    Name = "${var.name}_rt"
  }
}

#route table for the private subnet
resource "aws_route_table" "routing_private" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_private_gateway_id
  }
}

# route table associations for the public subnet
resource "aws_route_table_association" "routing_association_1" {
  subnet_id       = aws_subnet.public_subnet_1.id
  route_table_id  = aws_route_table.routing_public.id
}

resource "aws_route_table_association" "routing_association_2" {
  subnet_id       = aws_subnet.public_subnet_2.id
  route_table_id  = aws_route_table.routing_public.id 
}

# associate the route table with the private subnet
resource "aws_route_table_association" "routing_assoc_private" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.routing_private.id
}

