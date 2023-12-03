export APP_NAME="backup_s3"
export AWS_ACCESS_KEY_ID=$(shell aws configure get aws_access_key_id)
export AWS_SESSION_TOKEN=$(shell aws configure get aws_session_token)
export AWS_SECRET_ACCESS_KEY=$(shell aws configure get aws_secret_access_key)


build:
	docker build -t ${APP_NAME} .

run:
	docker run \
		-e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
		-e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
		-e AWS_SESSION_TOKEN="${AWS_SESSION_TOKEN}" \
		-it ${APP_NAME}
