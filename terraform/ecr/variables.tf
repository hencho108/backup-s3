variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
}

variable "ecr_repo_name" {
  description = "Name of the ECR repository"
  type        = string
}
