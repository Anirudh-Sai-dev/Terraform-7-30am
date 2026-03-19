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
#module "ec2" {
 # source = "./modules/ec2"

  #ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux (update if needed)
  #instance_type = "t2.micro"

  #subnet_id = module.vpc.public_subnet_ids[0]
#}