module "security_group_alb" {
  source = "./modules/security_group"
  name_secgroup = "load_balancer_security_group"
  vpc_id = module.my_vpc.vpc_id

  ingress_rules = [ 
    {   
      from_port   = 8080
      to_port     = 8080
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egress_rules = [
    {
      from_port      = 0
      to_port        = 0
      protocol       = "-1"
      cidr_blocks    = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
}

module "security_group_ec2" {
  source = "./modules/security_group"
  name_secgroup = "ec2_security_group"
  vpc_id = module.my_vpc.vpc_id
  ingress_rules = [ 
    {   
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = []
      security_groups = [module.security_group_alb.security_group_id]
    },
    {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      security_groups = []
    }
  ]

  egress_rules = [
    {
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
}

module "my_vpc" {
  source            = "./modules/vpc"
  vpc_name          = "my_vpc"
  cidr_block        = "10.0.0.0/16"
  subnet_public_id  = module.subnet_and_routes.public_subnet_ids[0]
  private_ip_aws_eip = "10.0.0.5"
}

module "subnet_and_routes" {
  source                 = "./modules/subnet"
  name                   = "my_subnet"
  vpc_id                 = module.my_vpc.vpc_id
  public_subnet_1_cidr   = "10.0.1.0/24"
  public_subnet_2_cidr   = "10.0.2.0/24"
  private_subnet_cidr    = "10.0.3.0/24"
  internet_gateway_id    = module.my_vpc.internet_gateway_id
  nat_private_gateway_id = module.my_vpc.nat_private_gateway_id
}

module "bastion_ec2" {
  source            = "./modules/ec2"
  ami_key           = "amazon_linux"
  instance_name     = "bastion"
  instance_type     = "t2.micro"
  key_pair          = var.key_pair
  security_groups   = [module.security_group_ec2.security_group_id]
  subnet_id         = module.subnet_and_routes.public_subnet_ids[0]
}

module "web_instance_1" {
  source            = "./modules/ec2"

  ami_key           = "amazon_linux"
  instance_name     = "web_instance_1"
  instance_type     = "t2.micro"
  key_pair          = var.key_pair
  security_groups   = [module.security_group_ec2.security_group_id]
  subnet_id         = module.subnet_and_routes.private_subnet_id

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              echo "Instance 1" > /var/www/html/index.html
              systemctl start httpd
              systemctl enable httpd
              EOF
}


module "web_instance_2" {
  source            = "./modules/ec2"

  ami_key           = "amazon_linux"
  instance_name     = "web_instance_2"
  instance_type     = "t2.micro"
  key_pair          = var.key_pair
  security_groups   = [module.security_group_ec2.security_group_id]
  subnet_id         = module.subnet_and_routes.private_subnet_id

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              echo "Instance 2" > /var/www/html/index.html
              systemctl start httpd
              systemctl enable httpd
              EOF
}


module "load_balancer" {
  source = "./modules/alb"

  elb_name              = "loadBalancerApp"
  load_balancer_type    = "application"
  is_internal           = false
  security_groups       = [ module.security_group_alb.security_group_id ]
  subnet                = module.subnet_and_routes.public_subnet_ids
  ec2_instance_name     = "terraform-lab"
  vpc_id                = module.my_vpc.vpc_id
  asg_name              = ""

  health_check = {
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 40
  }
}


