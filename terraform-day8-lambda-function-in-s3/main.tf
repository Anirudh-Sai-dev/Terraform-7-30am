resource "aws_s3_bucket" "name" {
  bucket = "terraform-lambda-function-day8"
  tags = {
    Name        = "terraform-lambda-function-day8"
  }
}

resource "aws_s3_object" "name" {
    bucket = aws_s3_bucket.name.bucket
    key    = "lambda/lambda_function.zip"
    source = "lambda_function.zip"
    etag = filemd5("lambda_function.zip")
  
}
resource "aws_iam_role" "name" {
    name = "lambda_execution_role"
    
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
            Service = "lambda.amazonaws.com"
        }
        }]
    })
}

resource "aws_iam_role_policy_attachment" "name" {
    role       = aws_iam_role.name.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "s3_read_access" {
    role       = aws_iam_role.name.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
resource "aws_lambda_function" "name" {
    function_name = "terraform-lambda-function-day8"
    s3_bucket     = aws_s3_bucket.name.bucket
    role          = aws_iam_role.name.arn
    s3_key        = aws_s3_object.name.key
    handler       = "lambda_function.lambda_handler"
    runtime       = "python3.12"

    timeout       = 900
    memory_size   = 128


  
}