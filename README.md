# backup-s3

## Overview

This project automates the deployment of a backup service that periodically copies data from a source S3 bucket to a backup S3 bucket on AWS. It uses AWS Lambda for processing, ECR for container image storage, and Terraform for infrastructure as code.

## Features

- **Automated Backup**: Configurable to run at a scheduled time.
- **Serverless Architecture**: Utilizes AWS Lambda for efficient, event-driven processing.
- **Containerized Application**: Dockerized Python application for easy deployment and isolation.
- **Infrastructure as Code**: Managed through Terraform, ensuring consistent and repeatable setups.

## Prerequisites

- AWS CLI, configured with appropriate access
- Docker
- Terraform

## Repository Structure

- `/terraform`: Contains Terraform configurations split into two directories:
  - `/ecr`: For ECR repository creation.
  - `/lambda`: For Lambda function and related resources.
- `/config`: Contains the YAML configuration file.
- `/src`: Contains the application's source code.
- `Dockerfile`: Docker configuration for the Lambda function.
- `main.py`: Python script executed by the Lambda function.
- `Makefile`: Contains commands to facilitate building, deploying, and destroying the infrastructure.
- `README.md`: Documentation for the project.

## Setup and Deployment

1. **Configure AWS CLI**: Make sure AWS CLI is installed and configured with the necessary access permissions.
2. **Define Environment Variables**:
   - Copy `.env.example` to `.env` and fill in the required AWS and application-specific variables.
3. **Deploy Infrastructure**:
   - Run `make deploy` to deploy the ECR repository, push the Docker image, and set up the Lambda function along with its necessary resources.
4. **Verify Deployment**:
   - Check the AWS Management Console to ensure that resources are deployed correctly.

## Usage

- The Lambda function is triggered as per the schedule defined in the CloudWatch Event Rule (default is every day at 3 AM UTC).
- The function copies data from the specified source S3 bucket to the backup S3 bucket.

## Makefile Commands

- `build`: Builds the Docker image.
- `deploy`: Deploys the entire infrastructure and the application.
- `destroy`: Removes all deployed AWS resources.

## Terraform Configuration

- Variables are defined in `variables.tf` files within each Terraform directory.
- The ECR and Lambda resources are managed separately to allow for independent updates.

## Troubleshooting

- **Lambda Errors**: Check the AWS Lambda console for logs and error messages.
- **Terraform Issues**: Run `terraform plan` to identify configuration mismatches.

## Future Enhancements

- Integrate CI/CD for automated builds and deployments.
- Implement monitoring and alerting for backup failures.

---
