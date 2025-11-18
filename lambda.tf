# Lambda function
resource "aws_lambda_function" "image_processor" {
  filename         = var.lambda_deployment_package
  function_name    = "${var.project_name}-${var.environment}"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_function"
  source_code_hash = filebase64sha256(var.lambda_deployment_package)
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size

  environment {
    variables = {
      DESTINATION_BUCKET     = aws_s3_bucket.destination.id
      SOURCE_BUCKET         = aws_s3_bucket.source.id
      DISCORD_WEBHOOK_URL   = var.discord_webhook_url
      ENABLE_NOTIFICATIONS  = var.enable_notifications
      DEBUG                 = var.environment == "dev" ? "true" : "false"
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda_logs,
    aws_iam_role_policy.lambda_logging,
    aws_iam_role_policy.lambda_s3
  ]

  tags = {
    Name = "${var.project_name}-${var.environment}"
  }
}

# Lambda permission for S3 to invoke the function
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.source.arn
}