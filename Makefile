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
export ECR_REPO_URI=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${TF_VAR_ecr_repo_name}:latest

# Define the paths to Terraform directories
ECR_TERRAFORM_DIR := terraform/ecr
LAMBDA_TERRAFORM_DIR := terraform/lambda

.PHONY: build run test ecr-login push-image terraform-apply-ecr terraform-apply-lambda

build:
    docker build -t ${APP_NAME} --target runtime .

run:
    docker run \
        -e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
        -e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
        -e AWS_SESSION_TOKEN="${AWS_SESSION_TOKEN}" \
        -it ${APP_NAME}
        -p 9000:8080
        -v ~/.aws/:/root/.aws/ ${APP_NAME}:latest

ecr-login:
    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

push-image:
    docker tag ${APP_NAME}:latest ${ECR_REPO_URI}
    docker push ${ECR_REPO_URI}

terraform-apply-ecr:
    cd ${ECR_TERRAFORM_DIR} && \
    terraform init && \
    terraform apply -target=aws_ecr_repository.ecr_repo -auto-approve

terraform-apply-lambda:
    cd ${LAMBDA_TERRAFORM_DIR} && \
    terraform init && \
    terraform apply -var="ecr_repository_uri=${ECR_REPO_URI}" -auto-approve

terraform-destroy-ecr:
    cd ${ECR_TERRAFORM_DIR} && \
    aws ecr delete-repository --repository-name ${TF_VAR_ecr_repo_name} --force || true && \
    terraform destroy -auto-approve

terraform-destroy-lambda:
    aws s3 rm s3://${TF_VAR_backup_bucket_name} --recursive || true && \
    cd ${LAMBDA_TERRAFORM_DIR} && \
    terraform destroy -var="ecr_repository_uri=dummy" -auto-approve

deploy: build ecr-login terraform-apply-ecr push-image terraform-apply-lambda
    @echo "Deployment complete."

destroy: terraform-destroy-lambda terraform-destroy-ecr
    @echo "Destruction complete."
