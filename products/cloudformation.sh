#!/bin/bash -eu
SCRIPT_DIR=$(cd $(dirname $0); pwd)

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
        --product|-p)
            product=${2}
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

if [ -z "$product" ] || [ ! -d "$SCRIPT_DIR/$product" ]; then
    while true; do
        read -p 'What product do you deploy to? : ' product
        if [ -n "$product" ] && [ -d "$SCRIPT_DIR/$product" ]; then
            break
        fi
    done
fi

if [ -z "$env" ] || [ ! -d "$SCRIPT_DIR/$product/$env" ]; then
    while true; do
        read -p 'What environment do you deploy to? ( dev / prd ) : ' env
        if [ -n "$env" ] && [ -d "$SCRIPT_DIR/$product/$env" ]; then
            break
        fi
    done
fi

if [ -z "$template" ] || [ ! -f "$SCRIPT_DIR/$product/$env/$template.json" ]; then
    while true; do
        read -p 'What template do you deploy to? : ' template
        if [ -n "$template" ] && [ -f "$SCRIPT_DIR/$product/$env/$template.json" ]; then
            break
        fi
    done
fi

# ------------------------------------------------------------------------------------------------------
# Parameters
# ------------------------------------------------------------------------------------------------------
networks=`cat $SCRIPT_DIR/../resources/$env/networks.json | jq -r '. | to_entries | map("\(.key)=\(.value|tostring)") | .[]' | tr '\n' ' ' | awk '{print}'`
params=`cat $SCRIPT_DIR/$product/$env/$template.json | jq -r '. | to_entries | map("\(.key)=\(.value|tostring)") | .[]' | tr '\n' ' ' | awk '{print}'`
platform=`cat $SCRIPT_DIR/$product/$env/$template.json | jq -r '.PlatformName'`

# ------------------------------------------------------------------------------------------------------
# Package
# ------------------------------------------------------------------------------------------------------
artifact_bucket=`aws cloudformation list-exports | jq -r '.Exports[]' | jq -r 'select(.Name | test("'$platform':ArtifactBucket")) | .Value'`
aws cloudformation package \
    --template-file $SCRIPT_DIR/$product/$env/cfn-stack-$template.yml \
    --s3-bucket $artifact_bucket \
    --s3-prefix products/$product/cloudformation \
    --output-template-file $SCRIPT_DIR/$product/$env/.cfn-stack-$template.yml
if [ $? -ne 0 ]; then
    exit $?
fi

# ------------------------------------------------------------------------------------------------------
# Deploy
# ------------------------------------------------------------------------------------------------------
aws cloudformation deploy \
    --template-file $SCRIPT_DIR/$product/$env/.cfn-stack-$template.yml \
    --stack-name $platform-$product-$template \
    --parameter-overrides $params $networks \
    --capabilities CAPABILITY_NAMED_IAM
if [ $? -ne 0 ]; then
    exit $?
fi
