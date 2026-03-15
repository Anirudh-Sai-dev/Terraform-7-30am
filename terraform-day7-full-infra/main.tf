
resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "test_vpc"
    }
}

resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    tags = {
      Name = "public-subnet-test-1"
    }
}

resource "aws_subnet" "name" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"
    tags = {
      Name = "private-subnet-test-1"
    } 
}

resource "aws_internet_gateway" "name" {
    vpc_id = aws_vpc.vpc.id
    tags = {
      Name = "custom-igw"
    } 
}

resource "aws_route_table" "name" {
    vpc_id = aws_vpc.vpc.id
    tags = {
      Name = "public_route_table"
    }
}

resource "aws_route" "igw_route" {
  route_table_id         = aws_route_table.name.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id         = aws_internet_gateway.name.id
}

resource "aws_route_table_association" "name" {
    subnet_id = aws_subnet.name.id
    route_table_id = aws_route_table.name.id
}

resource "aws_eip" "nat" {
  count  = 2
  domain = "vpc"
}

resource "aws_nat_gateway" "regional_nat" {
  vpc_id            = aws_vpc.vpc.id
  availability_mode = "regional"

  # Assigning first EIP to the first AZ
  availability_zone_address {
    allocation_ids    = [aws_eip.nat[0].id]
    availability_zone = "us-east-1a"
  }

  # Assigning second EIP to the second AZ
  availability_zone_address {
    allocation_ids    = [aws_eip.nat[1].id]
    availability_zone = "us-east-1b"
  }
}

resource "aws_route_table" "NAT" {
    vpc_id = aws_vpc.vpc.id
    tags = {
      Name = "Nat-route-table"
    }
}

resource "aws_route" "private_nat_route" {
  route_table_id         = aws_route_table.NAT.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.regional_nat.id
}


resource "aws_route_table_association" "nat_route" {
    subnet_id = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.NAT.id
}


resource "aws_instance" "name" {
    ami = "ami-02dfbd4ff395f2a1b"
    instance_type = "t3.micro"
    subnet_id = aws_subnet.name.id
    #iam_instance_profile = "cross-region-s3-role"
    tags = {
        Name = "bastion_instance"
    }
}

resource "aws_security_group" "name" {
    name = "Bastion-SG-1"
    description = "allows ssh for dev"
    vpc_id = aws_vpc.vpc.id

    ingress {
        description = "SSH access"
        to_port = 22
        from_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "bastion-sg"
    }
}