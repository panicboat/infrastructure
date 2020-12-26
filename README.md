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

# Usage

## Initialize ( at once )

1. Create s3 bucket for Artifact.
```bash
sh artifacts/cloudformation.sh
```

2. Deploy initial resources.
```bash
sh initialize/cloudformation.sh -e $env -p base
```

## Product Base

```bash
sh initialize/cloudformation.sh -e $env -p $product
```

## Project Service

1. Create TaskDefinitions.
```bash
template_path=modules/ecs/task-definitions.yml.erb
parameter_path=projects/$project/$env/environments.yml
output_path=projects/.task-definitions.yml
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
