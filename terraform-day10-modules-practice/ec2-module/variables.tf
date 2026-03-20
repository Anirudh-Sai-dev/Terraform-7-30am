variable "ami_id" {
  type = string
  description = "The AMI ID to use for the EC2 instance"
}

variable "instance_type" {
  type = string
  description = "The type of EC2 instance to launch"
}

variable "subnet_id" {
  type = string
  description = "The ID of the subnet in which to launch the EC2 instance"
}