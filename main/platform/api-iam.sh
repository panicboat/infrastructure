#!/bin/bash -eu
SCRIPT_DIR=$(cd $(dirname $0); pwd)/../../cfn/platform/api-iam

# ------------------------------------------------------------------------------------------------------
# Input Option
# ------------------------------------------------------------------------------------------------------
while [ $# -gt 0 ];
do
    case ${1} in
        --environment|-e)
            env=${2}
            shift
        ;;
        --template|-t)
            template=${2}
            shift
        ;;
        *)
            echo "[ERROR] Invalid option '${1}'"
            exit 1
        ;;
    esac
    shift
done

if [ -z "$env" ] || [ ! -d "$SCRIPT_DIR/$env" ]; then
    while true; do
        read -p 'What environment do you deploy to? ( dev / prd ) : ' env
        if [ -n "$env" ] && [ -d "$SCRIPT_DIR/$env" ]; then
            break
        fi
    done
fi

if [ -z "$template" ] || [ ! -f "$SCRIPT_DIR/$env/$template.json" ]; then
    while true; do
        read -p 'What template do you deploy to? : ' template
        if [ -n "$template" ] && [ -f "$SCRIPT_DIR/$env/$template.json" ]; then
            break
        fi
    done
fi

# ------------------------------------------------------------------------------------------------------
# Parameters
# ------------------------------------------------------------------------------------------------------
params=`cat $SCRIPT_DIR/$env/$template.json | jq -r '. | to_entries | map("\(.key)=\(.value|tostring)") | .[]' | tr '\n' ' ' | awk '{print}'`
platform=`cat $SCRIPT_DIR/$env/$template.json | jq -r '.PlatformName'`
product=`cat $SCRIPT_DIR/$env/$template.json | jq -r '.ProductName'`

# ------------------------------------------------------------------------------------------------------
# Package
# ------------------------------------------------------------------------------------------------------
artifact_bucket=`aws cloudformation list-exports | jq -r '.Exports[]' | jq -r 'select(.Name | test("'$platform':ArtifactBucket")) | .Value'`
aws cloudformation package \
    --template-file $SCRIPT_DIR/cfn-stack-$template.yml \
    --s3-bucket $artifact_bucket \
    --s3-prefix cloudformation/projects \
    --output-template-file $SCRIPT_DIR/$env/.cfn-stack-$template.yml
if [ $? -ne 0 ]; then
    exit $?
fi

# ------------------------------------------------------------------------------------------------------
# Deploy
# ------------------------------------------------------------------------------------------------------
aws cloudformation deploy \
    --template-file $SCRIPT_DIR/$env/.cfn-stack-$template.yml \
    --stack-name $product-$project-$template \
    --parameter-overrides $params Environment=$env \
    --capabilities CAPABILITY_NAMED_IAM
if [ $? -ne 0 ]; then
    exit $?
fi
