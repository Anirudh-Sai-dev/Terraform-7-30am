# allowed_ports variable is a map that defines the port number as the key and the corresponding CIDR block as the value.
# This allows us to easily manage and update our security group rules by simply modifying the variable values without changing the resource configuration.
# with the map variable it is possible to have multiple rules for different CIDR blocks

variable "allowed_ports" {
    type = map(string)
    default = {
    #key = value
    22    = "203.0.113.0/24"    # SSH (Restrict to office IP)
    80    = "0.0.0.0/0"         # HTTP (Public)
    443   = "0.0.0.0/0"         # HTTPS (Public)
    8080  = "10.0.0.0/16"       # Internal App (Restrict to VPC)
    9000  = "192.168.1.0/24"    # SonarQube/Jenkins (Restrict to VPN)
    3389  = "10.0.1.0/24"
    3000  = "10.0.2.0/24"

  }
}

resource "aws_security_group" "devops-project-veera" {
  name        = "terraform-practice-sg"
  description = "Allow TLS inbound traffic"

#Ingress rules with same source but different ports using for loop

  #ingress = [
    # for port in [22, 80, 443, 8080, 9000, 3000, 8082, 8081] : {
    #   description      = "inbound rules"
    #   from_port        = port
    #   to_port          = port
    #   protocol         = "tcp"
    #   cidr_blocks      = ["0.0.0.0/0"]
    #   ipv6_cidr_blocks = []
    #   prefix_list_ids  = []
    #   security_groups  = []
    #   self             = false
    
  #]

  #dynamic ingress rules for different ports and CIDR blocks using for_each loop
  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      description      = "inbound rules for port ${ingress.key}"
      from_port        = ingress.key
      to_port          = ingress.key
      protocol         = "tcp"
      cidr_blocks      = [ingress.value]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-practice-sg"
  }
}