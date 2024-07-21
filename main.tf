resource "aws_instance" "app_server" {
    provider = aws
    instance_type = var.instance_type
    ami = var.image_id
    
}