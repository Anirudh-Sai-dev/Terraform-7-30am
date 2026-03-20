provider "aws" {
  region = "us-east-1"
}

# Call VPC Module
module "vpc" {
  source = "./vpc-module"

  vpc_cidr        = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24"]
  private_subnets = ["10.0.2.0/24"]
}

# Call EC2 Module
module "ec2" {
  source = "./ec2-module"

  ami_id           = "ami-02dfbd4ff395f2a1b"  # Amazon Linux (update if needed)
  instance_type = "t3.micro"

  subnet_id = module.vpc.public_subnet_ids[0]
}