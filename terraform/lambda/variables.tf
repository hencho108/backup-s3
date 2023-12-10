variable "ecr_repository_uri" {
  description = "URL of the ECR repository"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
}

variable "source_bucket_name" {
  description = "The name of the S3 bucket to be backed up"
  type        = string
}

variable "backup_bucket_name" {
  description = "The name of the S3 bucket to be used for backups"
  type        = string
}

variable "execution_role_name" {
  description = "Name of the execution role"
  type        = string
}

variable "iam_policy_name" {
  description = "Name of the IAM policy"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "cloudwatch_trigger_name" {
  description = "Name of the Cloudwatch trigger"
  type        = string
}

variable "schedule_expression" {
  description = "The schedule expression for the CloudWatch event rule"
  type        = string
  default     = "cron(0 3 * * ? *)" # Default to every day at 3 AM
}
