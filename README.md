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
read -p 'input product name : ' product
read -p 'input project name : ' project
read -p 'input env : ' env
```

## Initialize ( at once )

1. Create s3 bucket for Artifact.
```bash
sh main/artifacts.sh
```

2. Deploy network resources.
```bash
sh main/networks.sh
```

## Product initialize

1. Deploy product initialize
```bash
sh main/$product/initialize.sh
```

## Project Service

1. Create Template of TaskDefinitons.
```bash
template_path=cfn/modules/ecs/task-definitions.yml.erb
parameter_path=cfn/$product/$project/$env/environments.yml
output_path=cfn/$product/$project/$env/.task-definitions.yml
docker-compose run app bash -c "ruby engine.rb --template $template_path --parameter $parameter_path > $output_path"
```

2. Deploy Service.
```bash
sh projects/cloudformation.sh -e $env -p $project -t service
```

## Project Pipeline

```bash
sh projects/cloudformation.sh -e $env -p $project -t pipeline
```
