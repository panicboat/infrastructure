# infrastructure

# Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

## Require

- Your domain is registered with Route 53

- The `CICredential` are registered in AWS Secrets Manager.
```json
{
  "GitHubAccessToken": "GitHubアクセストークン",
  "GitHubUserName": "GitHubアカウント名",
  "DockerHubID": "DockerHubログインID",
  "DockerHubPassword": "DockerHubパスワード"
}
```

- [Docker](https://www.docker.com/)

# Usage

```bash
read -p 'input env : ' env
read -p 'input product name : ' PRODUCT
read -p 'input project name : ' PROJECT
read -p 'input service name : ' SERVICE
```

## Initialize ( at once )

1. Create s3 bucket for Artifact.
```bash
sh main/artifacts.sh
```

2. Deploy network resources.
```bash
sh main/networks.sh -e $ENV
```

## Product initialize

1. Deploy product initialize
```bash
sh main/$PRODUCT/initialize.sh -e $ENV
```

## Project Service

1. Create Template of TaskDefinitons.
```bash
TEMPLATE_FILE_PATH=cfn/modules/ecs/task-definitions.yml.erb
PARAMETER_FILE_PATH=cfn/$PRODUCT/$PROJECT/$ENV/environments.yml
OUTPUT_FILE_PATH=cfn/$PRODUCT/$PROJECT/.task-definitions.yml
docker-compose run app bash -c "ruby engine.rb --template $TEMPLATE_FILE_PATH --parameter $PARAMETER_FILE_PATH > $OUTPUT_FILE_PATH"
```

2. Deploy Service.
```bash
sh main/$PRODUCT/$SERVICE.sh -e $ENV -t service
```

## Project Pipeline

```bash
sh main/$PRODUCT/$SERVICE.sh -e $ENV -t pipeline
```
