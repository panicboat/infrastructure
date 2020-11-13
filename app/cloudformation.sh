#!/bin/bash -eu
SCRIPT_DIR=$(cd $(dirname $0); pwd)
cd $SCRIPT_DIR

#------------------------------------------------------------------------------------------------------
# Input Option
#------------------------------------------------------------------------------------------------------
while [ $# -gt 0 ];
do
    case ${1} in
        --environment|-e)
            env=${2}
            shift
        ;;
        --project|-p)
            project=${2}
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

if [ -z "$project" ] || [ ! -d "$SCRIPT_DIR/$project" ]; then
    while true; do
        read -p 'What project do you deploy to? : ' project
        if [ -n "$project" ] && [ -d "$SCRIPT_DIR/$project" ]; then
            break
        fi
    done
fi

if [ -z "$env" ] || [ ! -d "$SCRIPT_DIR/$project/$env" ]; then
    while true; do
        read -p 'What environment do you deploy to? ( dev / prd ) : ' env
        if [ -n "$env" ] && [ -d "$SCRIPT_DIR/$project/$env" ]; then
            break
        fi
    done
fi

if [ -z "$template" ] || [ ! -f "$SCRIPT_DIR/$project/$env/$template.json" ]; then
    while true; do
        read -p 'What template do you deploy to? : ' template
        if [ -n "$template" ] && [ -f "$SCRIPT_DIR/$project/$env/$template.json" ]; then
            break
        fi
    done
fi

#------------------------------------------------------------------------------------------------------
# Parameters
#------------------------------------------------------------------------------------------------------
params_json=$SCRIPT_DIR/$project/$env/$template.json
params=`cat $params_json | jq -r '. | to_entries | map("\(.key)=\(.value|tostring)") | .[]' | tr '\n' ' ' | awk '{print}'`
product=`cat $params_json | jq -r '.ProductName'`
project=`cat $params_json | jq -r '.ProjectName'`

#------------------------------------------------------------------------------------------------------
# Package
#------------------------------------------------------------------------------------------------------
s3_bucket=`aws cloudformation list-exports | jq -r '.Exports[]' | jq -r 'select(.Name | test("'$product':ArtifactBucket")) | .Value'`
aws cloudformation package \
    --template-file $SCRIPT_DIR/$project/cfn-stack-$template.yml \
    --s3-bucket $s3_bucket \
    --s3-prefix $project \
    --output-template-file $SCRIPT_DIR/$project/$env/.cfn-stack-$template.yml
if [ $? -ne 0 ]; then
    exit $?
fi

#------------------------------------------------------------------------------------------------------
# Deploy
#------------------------------------------------------------------------------------------------------
aws cloudformation deploy \
    --template-file $SCRIPT_DIR/$project/$env/.cfn-stack-$template.yml \
    --stack-name $product-$project \
    --parameter-overrides $params
if [ $? -ne 0 ]; then
    exit $?
fi
