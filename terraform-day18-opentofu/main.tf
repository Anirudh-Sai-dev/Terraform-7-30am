
#use tofu init tofu plan and tofu apply commands to create the infrastructure defined in this configuration file. This configuration file creates an AWS EC2 instance with the specified AMI and instance type, and tags it with the name "test-instance".


resource "aws_instance" "name" {
    ami = "ami-02dfbd4ff395f2a1b"
    instance_type = "t2.small"
    tags = {
        Name = "test-instance"
    }   
  
}

#opentofu fully open source terraform alternative, same hcl language, same commands, same state file, same providers, same modules, same configuration files, same workflow, but open source and free to use without any restrictions.
#tofu init, plan and apply commands are same as terraform, but the command is "tofu" instead of "terraform". It is fully compatible with terraform, so you can use the same configuration files and state files with tofu without any modifications.