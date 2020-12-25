# infrastructure

# Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

## Require

Register in AWS Secrets Manager.

```
{
  "GitHubAccessToken": "GitHubアクセストークン",
  "GitHubUserName": "GitHubアカウント名",
  "DockerHubID": "DockerHubログインID",
  "DockerHubPassword": "DockerHubパスワード"
}
```

# Usage

## Initialize ( at once )

```bash
sh artifacts/cloudformation.sh
sh initialize/cloudformation.sh -e dev -p base
```

## Provisioning Products

```
sh initialize/cloudformation.sh -e dev -p platform
```

## Project Service

```bash
sh products/cloudformation.sh -e dev -p api-iam -t service
```

## Project Pipeline

```bash
sh products/cloudformation.sh -e dev -p api-iam -t pipeline
```
