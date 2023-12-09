# Load environment variables from .env file
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

# Expose additional environment variables
export AWS_ACCESS_KEY_ID=$(shell aws configure get aws_access_key_id)
export AWS_SESSION_TOKEN=$(shell aws configure get aws_session_token)
export AWS_SECRET_ACCESS_KEY=$(shell aws configure get aws_secret_access_key)
export AWS_ACCOUNT_ID=$(shell aws sts get-caller-identity --query "Account" --output text)
export IMAGE_TAG=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${TF_VAR_ecr_repo_name}:latest

# Define the paths to Terraform directories
ECR_TERRAFORM_DIR := terraform/ecr
LAMBDA_TERRAFORM_DIR := terraform/lambda

.PHONY: build run test ecr-login push-image terraform-apply-ecr terraform-apply-lambda

build:
	docker build -t ${APP_NAME} .

run:
	docker run \
		-e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
		-e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
		-e AWS_SESSION_TOKEN="${AWS_SESSION_TOKEN}" \
		-it ${APP_NAME}

ecr-login:
	aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

push-image:
	docker tag ${APP_NAME}:latest ${IMAGE_TAG}
	docker push ${IMAGE_TAG}

terraform-apply-ecr:
	cd ${ECR_TERRAFORM_DIR} && \
	terraform init && \
	terraform apply -target=aws_ecr_repository.ecr_repo -auto-approve
	$(eval ECR_REPO_URL=$(shell cd $(ECR_TERRAFORM_DIR) && terraform output -raw ecr_repository_url))

terraform-apply-lambda:
	cd ${LAMBDA_TERRAFORM_DIR} && \
	terraform init && \
    terraform apply -var="ecr_repository_url=${ECR_REPO_URL}" -auto-approve

deploy: build ecr-login terraform-apply-ecr push-image terraform-apply-lambda
	@echo "Deployment complete."
