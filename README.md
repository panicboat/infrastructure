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

- [fillin](https://github.com/itchyny/fillin)

# Usage

## Initialize ( at once )

1. Create s3 bucket for Artifact.
```bash
fillin sh artifacts/cloudformation.sh
```

2. Deploy initial resources.
```bash
fillin sh initialize/cloudformation.sh -e {{env}} -p base
```

## Product Base

1. Create Template of RDS.
```bash
template_path=modules/base/rds.yml.erb
parameter_path=initialize/$product/$env/environments.yml
output_path=initialize/$product/.rds.yml
docker-compose run app bash -c "ruby engine.rb --template $template_path --parameter $parameter_path > $output_path"
```

2. Deploy Base for Product.
```bash
fillin sh initialize/cloudformation.sh -e {{env}} -p {{product}}
```

## Project Service

1. Create Template of TaskDefinitons.
```bash
template_path=modules/ecs/task-definitions.yml.erb
parameter_path=projects/$project/$env/environments.yml
output_path=projects/.task-definitions.yml
docker-compose run app bash -c "ruby engine.rb --template $template_path --parameter $parameter_path > $output_path"
```

2. Deploy Service.
```bash
fillin sh projects/cloudformation.sh -e {{env}} -p {{project}} -t service
```

## Project Pipeline

```bash
fillin sh projects/cloudformation.sh -e {{env}} -p {{project}} -t pipeline
```
