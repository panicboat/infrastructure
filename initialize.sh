#!/bin/bash -eu
SCRIPT_DIR=$(cd $(dirname $0); pwd)
# ------------------------------------------------------------------------------------------------------
# Parameters
# ------------------------------------------------------------------------------------------------------
params=`cat $SCRIPT_DIR/initialize.json | jq -r '. | to_entries | map("\(.key)=\(.value|tostring)") | .[]' | tr '\n' ' ' | awk '{print}'`
product=`cat $SCRIPT_DIR/initialize.json | jq -r '.ProductName'`
# ------------------------------------------------------------------------------------------------------
# PyPlate
# ------------------------------------------------------------------------------------------------------
aws cloudformation deploy \
    --stack-name PyPlate \
    --template-file ${SCRIPT_DIR}/pyplate.yml \
    --capabilities CAPABILITY_NAMED_IAM \
    --no-fail-on-empty-changeset
if [ $? -ne 0 ]; then
    exit $?
fi
# ------------------------------------------------------------------------------------------------------
# Initialize
# ------------------------------------------------------------------------------------------------------
aws cloudformation deploy \
    --stack-name $product-initialize \
    --template-file ${SCRIPT_DIR}/initialize.yml \
    --parameter-overrides $params \
    --no-fail-on-empty-changeset
if [ $? -ne 0 ]; then
    exit $?
fi
