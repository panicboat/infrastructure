#!/bin/bash -eu
SCRIPT_DIR=$(cd $(dirname $0); pwd)
# ------------------------------------------------------------------------------------------------------
# Parameters
# ------------------------------------------------------------------------------------------------------
params=`cat $SCRIPT_DIR/params.json | jq -r '. | to_entries | map("\(.key)=\(.value|tostring)") | .[]' | tr '\n' ' ' | awk '{print}'`
platform=`cat $SCRIPT_DIR/params.json | jq -r '.PlatformName'`
# ------------------------------------------------------------------------------------------------------
# S3 Bucket
# ------------------------------------------------------------------------------------------------------
aws cloudformation deploy \
    --stack-name $platform-artifacts \
    --template-file ${SCRIPT_DIR}/s3.yml \
    --parameter-overrides $params \
    --no-fail-on-empty-changeset
if [ $? -ne 0 ]; then
    exit $?
fi
