# Source bucket for uploaded images
resource "aws_s3_bucket" "source" {
  bucket = var.source_bucket_name

  tags = {
    Name = "${var.project_name}-source-${var.environment}"
  }
}

# Block public access to source bucket
resource "aws_s3_bucket_public_access_block" "source" {
  bucket = aws_s3_bucket.source.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning on source bucket
resource "aws_s3_bucket_versioning" "source" {
  bucket = aws_s3_bucket.source.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Destination bucket for processed images
resource "aws_s3_bucket" "destination" {
  bucket = var.destination_bucket_name

  tags = {
    Name = "${var.project_name}-destination-${var.environment}"
  }
}

# Block public access to destination bucket
resource "aws_s3_bucket_public_access_block" "destination" {
  bucket = aws_s3_bucket.destination.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning on destination bucket
resource "aws_s3_bucket_versioning" "destination" {
  bucket = aws_s3_bucket.destination.id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket notification to trigger Lambda
resource "aws_s3_bucket_notification" "source_notification" {
  bucket = aws_s3_bucket.source.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.image_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ""
  }

  depends_on = [aws_lambda_permission.allow_s3]
}