resource "aws_instance" "new_instace" {
    ami           = "ami-02dfbd4ff395f2a1b"
    instance_type = "t3.micro"

    # lifecycle {
    #   create_before_destroy = true
    # }
    #  lifecycle {
    # ignore_changes = [ tags ]
    # }
    lifecycle {
      prevent_destroy = true
      ignore_changes = [ tags ]
    }
    tags = {
        Name = "dev-instance-latest"
    }
}