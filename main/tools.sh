#!/bin/bash -eu
SCRIPT_DIR=$(cd $(dirname $0); pwd)/../cfn/tools

# ------------------------------------------------------------------------------------------------------
# Package
# ------------------------------------------------------------------------------------------------------
artifact_bucket=`aws cloudformation list-exports | jq -r '.Exports[]' | jq -r 'select(.Name | test("'$platform':ArtifactBucket")) | .Value'`
aws cloudformation package \
    --template-file $SCRIPT_DIR/cfn-stack-template.yml \
    --s3-bucket $artifact_bucket \
    --s3-prefix cloudformation/tools \
    --output-template-file $SCRIPT_DIR/.cfn-stack-template.yml
if [ $? -ne 0 ]; then
    exit $?
fi

# ------------------------------------------------------------------------------------------------------
# Deploy
# ------------------------------------------------------------------------------------------------------
aws cloudformation deploy \
    --template-file $SCRIPT_DIR/.cfn-stack-template.yml \
    --stack-name panicboat-tools \
    --capabilities CAPABILITY_NAMED_IAM \
    --region us-east-1
if [ $? -ne 0 ]; then
    exit $?
fi
