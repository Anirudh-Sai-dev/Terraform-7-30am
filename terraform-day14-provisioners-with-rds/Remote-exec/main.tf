# Example EC2 instance (replace with yours if already existing)
resource "aws_vpc" "new-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "new-vpc"
    }
  
}

resource "aws_subnet" "subnet-1" {
    vpc_id = aws_vpc.new-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    tags = {
        Name = "subnet-1"
    }
}

resource "aws_subnet" "subnet-2" {
    vpc_id = aws_vpc.new-vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"
    tags = {
        Name = "subnet-2"
    }
}

# resource "aws_internet_gateway" "igw" {
#     vpc_id = aws_vpc.new-vpc.id
#     tags = {
#         Name = "new-igw"
#     }
  
# }

# resource "aws_nat_gateway" "nat-gateway" {
#     vpc_id = aws_vpc.new-vpc.id
#     tags = {
#         Name = "nat-gateway"
#     }
# }
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id            = aws_vpc.new-vpc.id
  service_name      = "com.amazonaws.us-east-1.secretsmanager"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.subnet-1.id,
    aws_subnet.subnet-2.id
  ]

  security_group_ids = [aws_security_group.ec2_sg.id]
}

resource "aws_db_subnet_group" "rds_subnet_group" {
    name       = "rds-subnet-group"
    subnet_ids = [aws_subnet.subnet-1.id, aws_subnet.subnet-2.id]
}

resource "aws_security_group" "ec2_sg" {
  name = "ec2-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # restrict later
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  name = "rds-sg"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-secrets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "secrets_policy" {
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "secretsmanager:GetSecretValue"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "sql_runner" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type          = "t3.micro"
  key_name               = "keydevops730am"                # Replace with your key pair name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id              = aws_subnet.subnet-1.id
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "SQL-Runner"
  }
}

resource "aws_db_instance" "mysql_rds" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "dev"
  username             = "admin"
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  manage_master_user_password = true # In production, use secrets manager or parameter store
  skip_final_snapshot  = true
  publicly_accessible  = false

}

# Deploy SQL remotely using null_resource + remote-exec
resource "null_resource" "remote_sql_exec" {
  depends_on = [aws_db_instance.mysql_rds, aws_instance.sql_runner]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("C:/Users/HI/Downloads/keydevops730am.pem")   # Replace with your PEM file path
    host        = aws_instance.sql_runner.public_ip
  }

  provisioner "file" {
    source      = "init.sql"
    destination = "/tmp/init.sql"
  }

  provisioner "remote-exec" {
      inline = [
         "sudo yum update -y",
         "sudo yum install -y mysql jq aws-cli",

         "mysql -h ${aws_db_instance.mysql_rds.address} -u ${aws_db_instance.mysql_rds.username} -p$(aws secretsmanager get-secret-value --secret-id ${aws_db_instance.mysql_rds.master_user_secret[0].secret_arn} --query SecretString --output text | jq -r .password) < /tmp/init.sql"
        ]    
  }

  triggers = {
    always_run = timestamp() #trigger every time apply 
  }
}




# ADD RDS creation script only accessbale interanlly si disable public access 
# Remote provisioner server also should create insame vpc 
# enable secrets fro secret manager and call secrets into RDS for this process vpc endpoint is require or nat gateway is required to access secrets to rds internall as secremanger is not in side VPC sefrvice 