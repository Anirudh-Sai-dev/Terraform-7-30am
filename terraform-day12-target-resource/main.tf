

resource "aws_instance" "name" {
    ami           = "ami-02dfbd4ff395f2a1b"
    instance_type = "t2.micro"
  
}
resource "aws_s3_bucket" "name" {
    bucket = "terraform-buckete-practice-targets"
  
}

#we can targte specific resource to update or destroy by using -target option in terraform plan and apply command
#terraform plan -target=aws_instance.name
#if multiple resource we can use -target multiple times
#terraform plan -target=aws_instance.name -target=aws_s3_bucket.name