# Sample 3tier app
This repo contains code for a Django multi-tier application.

The application overview is as follows

```
web <=> api <=> db
```

The folders `web` and `api` respectively describe how to install and run each app.

## Requirements
  - SAM Cli installed: [Getting started with the AWS SAM](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-getting-started.html)
  - AWS Account
  - IAM user with Git Credentials for Codecommit: [IAM Git Credentials](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_ssh-keys.html)
  - Docker and Docker compose.

## Getting started
Firstly install the requirements, then create the pipeline. this can be done with the Makefile command
```bash
    make pipeline
```
Once this is created, you can push to the CodeCommit repo, which will start the build process. 
This will fail the first time, as there are no images in the repo. so remedy this, simply push the docker images from
your local machine.
```bash
    make docker_build
```
To create the CloudFormation infrastructure you can use the command:
```bash
    make sam_deploy
```
which will build the infra, although the pipeline will do this for you as well.

## Architecture
This is an AWS application, with the following architecture:

![architecture](/images/diagram.png)

* CDN -> CloudFront
* Database -> Postgres on RDS
* API -> Docker on Elastic Container Service (ECS)
* Web -> Docker on Elastic Container Service (ECS)
* Application loadbalancers are used for High availability

## IaC - CloudFormation
The architecture is written in CloudFormation. The root template.yaml provisions the nested stacks in cfn/ dir.

## Instance Failures
The system is highly-available and uses application load-balancers backed by fargate instances.

## Rolling Updates in the pipeline
The pipeline can update the components without any downtime. Also the deployment of new code will be deployed automatically.
![pipeline](/images/pipeline.png)

### Tests
A test is run in the pipeline against the docker-compose stack to ensure that it is running correctly.
To run the tests locally use the Makefile command:
```bash
    make test
```
## RDS Database
The database runs on RDS, and is automatically backed up daily.

## CloudWatch Logs and Metrics
All logs are sent to CloudWatch, as well as metrics for the components.

## CloudFront - Content Distribution Network
CloudFront - a content distribution network is used to distribute the web content.
