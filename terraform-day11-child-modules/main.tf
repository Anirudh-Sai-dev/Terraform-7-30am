module "vpc" {
    source = ".//modules/vpc"
    vpc_cidr = var.vpc_cidr
    public_subnets = var.public_subnet_cidrs
    private_subnets = var.private_subnet_cidrs
    public_az = var.public_az
    private_az = var.private_az
    igw_route_destination = var.igw_route_destination
    nat_availability_mode = var.nat_availability_mode
    nat_route_destination = var.nat_route_destination
  
}

module "SG" {
    source = ".//modules/SG"
  
}

module "ec2" {
    source = ".//modules/ec2"
    instance_type = var.instance_type
    ami_id = var.ami
}

module "rds" {
    source = ".//modules/rds"  
}

module "s3" {
    source = ".//modules/s3"
}


