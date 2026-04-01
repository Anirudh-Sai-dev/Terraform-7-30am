# VPC and Subnet Configuration module variables
variable "vpc_cidr" {
    description = "CIDR block for the VPC"
    type        = string
}

variable "public_subnet_cidrs" {
    description = "List of CIDR blocks for public subnets"
    type        = list(string)
}

variable "private_subnet_cidrs" {
    description = "List of CIDR blocks for private subnets"
    type        = list(string)
}

variable "public_az" {
    description = "List of availability zones for public subnets"
    type        = list(string)
}

variable "private_az" {
    description = "List of availability zones for private subnets"
    type        = list(string)
}

variable "igw_route_destination" {
    description = "Destination CIDR block for the internet gateway route"
    type        = string
}

variable "nat_availability_mode" {
    description = "Availability mode for NAT Gateway (e.g., 'single' or 'regional')"
    type        = string
}

variable "nat_route_destination" {
    description = "Destination CIDR block for the NAT gateway route"
    type        = string
}

# EC2 module variables
variable "instance_type" {
    description = "Instance type for EC2"
    type        = string
}
variable "ami" {
    description = "AMI ID for EC2"
    type        = string
}

