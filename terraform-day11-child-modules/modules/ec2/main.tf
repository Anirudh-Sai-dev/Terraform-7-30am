resource "aws_instance" "bastion_host" {
    instance_type = var.instance_type
    subnet_id = aws_subnet.public[0].id
    ami = var.ami_id

    vpc_security_group_ids = aws_security_group.bastion_host.id

    tags = {
        Name = "Bastion_host_instance"
    }

}

resource "aws_instance" "frontend_server" {
    instance_type = var.instance_type
    subnet_id = aws_subnet.private[0].id
    ami = var.ami_id

    tags = {
        Name = "Frontend_server_instance"
    }
  
}