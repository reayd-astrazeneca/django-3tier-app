STACK_NAME := django-3tier-app
REPOSITORY_NAME := django-3tier-app
PROFILE_NAME := awsbot
SAM_BUCKET := aws-sam-cli-managed-default-samclisourcebucket-1n27e08u2rhea
ECR_REPO ?=

release: pipeline
	@echo "Enter commit message:"
	@read REPLY; \
	git add --all; \
	git commit -m "$$REPLY"; \
	git push origin

docker_login:
	aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 701168364071.dkr.ecr.eu-west-1.amazonaws.com

docker_build:
	$(MAKE) -C app
	$(MAKE) -C proxy

docker_compose:
	@docker-compose up -d --build --force-recreate

sam_build:
	@sam build --template template.yaml

sam_deploy: sam_build
	@sam deploy \
	  --profile awsbot \
	  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
	  --stack-name $(STACK_NAME) \
	  --s3-bucket $(SAM_BUCKET)

pipeline:
	-@sam build --template cfn/pipeline.yaml
	-@sam deploy \
	  --template cfn/pipeline.yaml \
	  --profile  $(PROFILE_NAME) \
	  --capabilities CAPABILITY_IAM \
	  --stack-name Pipeline-$(STACK_NAME) \
	  --parameter-overrides RepositoryName=$(REPOSITORY_NAME) StackName=$(STACK_NAME)

imagedefinitions:
	printf '[{"name":"django-web","imageUri":"$(ECR_REPO):web-$(CODEBUILD_RESOLVED_SOURCE_VERSION)"},{"name":"nginx-proxy","imageUri":"$(ECR_REPO):proxy-$(CODEBUILD_RESOLVED_SOURCE_VERSION)"}]' > imagedefinitions.web.json

test: docker_compose
	sleep 10
	curl -s http://localhost:8000/ | grep "3tier App"
	curl -s http://localhost/api/status | grep "time"

install_docker_compose:
	pip install docker-compose

clean_docker:
	-docker kill $(docker ps -a -q)
	# Delete all containers
	-docker rm $(docker ps -a -q)
	# Delete all images
	-docker rmi $(docker images -a -q)
	# Delete all volumes
	-docker system prune --volumes -f

sam_package:
	sam package --s3-bucket $(SAM_BUCKET) --s3-prefix sam --output-template-file template.yaml

install_awscli:
	pip uninstall -qy awscli
	curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
	unzip -oq /tmp/awscliv2.zip -d /tmp
	/tmp/aws/install
	aws --version

install: install_docker_compose install_awscli
	@echo install finished on `date`

pre_build: docker_login
	@echo pre_build finished on `date`

build: docker_build
	@echo build finished on `date`

post_build: imagedefinitions sam_package
	@echo post_build finished on `date`
