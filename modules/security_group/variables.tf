variable "name_secgroup" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    security_groups = optional(list(string)) # Opcional para las reglas de ingreso
  })) 
  default = []
}

variable "egress_rules" {
  description = "List of egress rules"
  type = list(object({
    from_port      = number
    to_port        = number
    protocol       = string
    cidr_blocks    = list(string)
    security_groups = optional(list(string)) # Opcional para las reglas de egreso
  }))
  default = []
}
