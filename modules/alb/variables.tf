variable "elb_name" {
  type = string
}

variable "load_balancer_type" {
  type = string
}

variable "is_internal" {
  type = bool
}

variable "ec2_instance_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "asg_name" {
  type = string
}

variable "security_groups" {
  type = list(string)
  default = []
}

variable "instances" {
  description = "The list of instances to register with the ELB"
  type        = list(string)
  default = [] 
}

variable "health_check" {
  type = object({
    path                = string
    interval            = number
    timeout             = number
    healthy_threshold   = number
    unhealthy_threshold = number
  })
}

variable "subnet" {
  type = list(string)
}