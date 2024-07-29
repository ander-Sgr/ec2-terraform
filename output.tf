output "load_balancer_dns" {
  value = "http://${module.load_balancer.alb_dns_name}:8080"
  description = "The dns for of the ALB we have to put the port 8080 at the end of the url"
}

output "bastion_ip" {
  value = module.bastion_ec2.bastion_ip
}

output "selected_ami_id_bastion" {
  value = module.bastion_ec2.selected_ami_id_bastion
}

output "private_ips" {
  value = [for instance in data.aws_instances.web_instances.ids : data.aws_instance.instance[instance].private_ip]
}
