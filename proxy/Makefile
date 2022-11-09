CODEBUILD_RESOLVED_SOURCE_VERSION ?= latest
APP_NAME ?= proxy
ECR_REPO ?= 701168364071.dkr.ecr.eu-west-1.amazonaws.com/django-3tier-app

all: build tag_latest push

build:
	docker build . -t $(ECR_REPO):$(APP_NAME)-$(CODEBUILD_RESOLVED_SOURCE_VERSION)

tag_latest:
	-docker tag $(ECR_REPO):$(APP_NAME)-$(CODEBUILD_RESOLVED_SOURCE_VERSION) $(ECR_REPO):$(APP_NAME)-latest

push:
	docker push $(ECR_REPO):$(APP_NAME)-$(CODEBUILD_RESOLVED_SOURCE_VERSION)
	docker push $(ECR_REPO):$(APP_NAME)-latest