resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "test_vpc"
    }

  
}

resource "aws_subnet" "new_subnet" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    tags = {
      Name = "public-subnet-1-new"
    }

  
}

resource "aws_instance" "name" {
    ami = "ami-02dfbd4ff395f2a1b"
    instance_type = "t3.micro"
    subnet_id = aws_subnet.new_subnet.id
    iam_instance_profile = "cross-region-s3-role"
    tags = {
        Name = "test_instance"
    }
  
}