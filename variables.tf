variable "region" {
  description   = "AWS region"
  type          = string
  default       = "us-east-1"
}

variable "allowed_ip" {
  type = string
}

variable "key_pair" {
  type = string
}