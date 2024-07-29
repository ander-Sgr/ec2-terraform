module "security_group_alb" {
  source = "./modules/security_group"
  name_secgroup = "load_balancer_security_group"
  vpc_id = module.my_vpc.vpc_id

  ingress_rules = [ 
    {   
      from_port   = 8080
      to_port     = 8080
      protocol    = "TCP"
      cidr_blocks = [var.allowed_ip]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"] 
      security_groups = [] 
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

resource "aws_launch_template" "web" {
  name_prefix   = "web-template"
  image_id      = "ami-0b72821e2f351e396"
  instance_type = "t2.micro"
  key_name      = var.key_pair

  vpc_security_group_ids = [module.security_group_ec2.security_group_id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              echo "<h1>Hello world from $(hostname -f)</h1>" > /var/www/html/index.html
              sed -i 's/^Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf
              sed -i 's/^<VirtualHost _default_:80>/<VirtualHost _default_:8080>/' /etc/httpd/conf/httpd.conf
              systemctl start httpd
              systemctl enable httpd
              EOF
  )
}

resource "aws_autoscaling_group" "web_asg" {
  desired_capacity = 2
  max_size = 2
  min_size = 2
  vpc_zone_identifier = [module.subnet_and_routes.private_subnet_id]
  target_group_arns = [module.load_balancer.target_group_arn]
  launch_template {
    id = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key = "Name"
    value = "web_serv"
    propagate_at_launch = true
  }
  
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
  asg_name              = aws_autoscaling_group.web_asg.name

  health_check = {
    path                = "/"
    port                = "8080"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 40
  }
}

data "aws_instances" "web_instances" {
  filter {
    name   = "tag:Name"
    values = ["web_serv"]
  }
}

data "aws_instance" "instance" {
  for_each = toset(data.aws_instances.web_instances.ids)

  instance_id = each.key
}