
resource "aws_iam_role" "ec2_s3_access_role" {
    name = "ec2_s3_access_role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            }
        ]
    })
  
}

resource "aws_iam_policy" "ec2_s3_access_policy" {
    name = "ec2_s3_access_policy"
    description = "Policy to allow EC2 instances to access S3 buckets"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "s3:GetObject",
                    "s3:ListBucket",
                    "s3:PutObject"
                ]
                Resource = [
                    "arn:aws:s3:::terraform-s3-state-day5",
                    "arn:aws:s3:::terraform-s3-state-day5/*"
                ]
            }
        ]
    })
  
}

resource "aws_iam_role_policy_attachment" "policy_attach_to_role" {
    policy_arn = aws_iam_policy.ec2_s3_access_policy.arn
    role      = aws_iam_role.ec2_s3_access_role.name
    depends_on = [aws_iam_policy.ec2_s3_access_policy, aws_iam_role.ec2_s3_access_role]
}   

resource "aws_iam_instance_profile" "ec2_profile" {
    name = "ec2_instance_profile"
    role = aws_iam_role.ec2_s3_access_role.name
  
}

resource "aws_instance" "ec2_instance" {
    ami = "ami-02dfbd4ff395f2a1b"
    instance_type = "t3.micro"
    iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
    tags = {
        Name = "EC2-with-S3-access"
    }
  
}

resource "aws_s3_bucket" "name" {
  bucket = "day9-practice-bucket-terraform"
  depends_on = [ aws_instance.ec2_instance ]
}