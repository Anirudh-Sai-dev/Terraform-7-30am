terraform {
  backend "s3" {
    #the bucket variable needs to have your s3 bucket name

    bucket = "terraform-s3-state-day5"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
