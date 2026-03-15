terraform {
  backend "s3" {
    bucket = "terraform-s3-state-day5"
    key    = "terraform.tfstate"
    region = "us-east-1"

    #remote backend with dynamodb

    dynamodb_table = "state_lockfile_table"
    encrypt = true
  }
}