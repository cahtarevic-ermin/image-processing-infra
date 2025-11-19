variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "image-processing"
}

variable "source_bucket_name" {
  description = "S3 bucket name for uploaded images"
  type        = string
}

variable "destination_bucket_name" {
  description = "S3 bucket name for processed images"
  type        = string
}

variable "lambda_runtime" {
  description = "Lambda function runtime"
  type        = string
  default     = "python3.12"
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 60
}

variable "lambda_memory_size" {
  description = "Lambda function memory in MB"
  type        = number
  default     = 256
}

variable "discord_webhook_url" {
  description = "Discord webhook URL for notifications"
  type        = string
  default     = ""
  sensitive   = true
}

variable "enable_notifications" {
  description = "Enable Discord notifications"
  type        = bool
  default     = true
}

variable "lambda_deployment_package" {
  description = "Path to Lambda deployment ZIP file"
  type        = string
  default     = "../image-processing-lambda/deployment/lambda.zip"
}