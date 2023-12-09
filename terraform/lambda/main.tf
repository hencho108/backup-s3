provider "aws" {
  region = var.aws_region
}

resource "aws_iam_role" "lambda_execution_role" {
  name = var.execution_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_policy" "lambda_s3_access" {
  name = var.iam_policy_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.source_bucket_name}",
          "arn:aws:s3:::${var.source_bucket_name}/*",
          "arn:aws:s3:::${var.backup_bucket_name}",
          "arn:aws:s3:::${var.backup_bucket_name}/*"
        ],
        Effect = "Allow",
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_attach" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_s3_access.arn
}

resource "aws_lambda_function" "lambda_function" {
  function_name = var.lambda_function_name
  architectures = ["arm64"]

  role         = aws_iam_role.lambda_execution_role.arn
  package_type = "Image"

  image_uri = var.ecr_repository_uri

  timeout     = 900
  memory_size = 128
}

resource "aws_s3_bucket" "example" {
  bucket = var.backup_bucket_name
}

resource "aws_cloudwatch_event_rule" "trigger" {
  name                = var.cloudwatch_trigger_name
  schedule_expression = "cron(0 3 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule = aws_cloudwatch_event_rule.trigger.name
  arn  = aws_lambda_function.lambda_function.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.trigger.arn
}

