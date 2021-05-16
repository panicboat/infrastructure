#!/bin/bash -eu
CFN_HOME=$(cd $(dirname $0); pwd)/../cfn

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
        *)
            echo "[ERROR] Invalid option '${1}'"
            exit 1
        ;;
    esac
    shift
done

if [ -z "$product" ] || [ ! -d "$CFN_HOME/$product" ]; then
    while true; do
        read -p 'What product do you deploy to? ( platform ) : ' product
        if [ -n "$product" ] && [ -d "$CFN_HOME/$product" ]; then
            break
        fi
    done
fi

if [ -z "$env" ] || [ ! -d "$CFN_HOME/$product/networks/$env" ]; then
    while true; do
        read -p 'What environment do you deploy to? ( dev / prd ) : ' env
        if [ -n "$env" ] && [ -d "$CFN_HOME/$product/networks/$env" ]; then
            break
        fi
    done
fi

SCRIPT_DIR=$CFN_HOME/$product/networks
# ------------------------------------------------------------------------------------------------------
# Parameters
# ------------------------------------------------------------------------------------------------------
params=`cat $SCRIPT_DIR/$env/params.json | jq -r '. | to_entries | map("\(.key)=\(.value|tostring)") | .[]' | tr '\n' ' ' | awk '{print}'`
organization=`cat $SCRIPT_DIR/$env/params.json | jq -r '.OrganizationName'`

# ------------------------------------------------------------------------------------------------------
# Package
# ------------------------------------------------------------------------------------------------------
artifact_bucket=`aws cloudformation list-exports | jq -r '.Exports[]' | jq -r 'select(.Name | test("'$organization':ArtifactBucket")) | .Value'`
aws cloudformation package \
    --template-file $CFN_HOME/modules/networks/cfn-stack-template.yml \
    --s3-bucket $artifact_bucket \
    --s3-prefix cloudformation/networks \
    --output-template-file $SCRIPT_DIR/$env/.cfn-stack-template.yml
if [ $? -ne 0 ]; then
    exit $?
fi

# ------------------------------------------------------------------------------------------------------
# Deploy
# ------------------------------------------------------------------------------------------------------
aws cloudformation deploy \
    --template-file $SCRIPT_DIR/$env/.cfn-stack-template.yml \
    --stack-name $organization-networks \
    --parameter-overrides $params Environment=$env \
    --capabilities CAPABILITY_NAMED_IAM
if [ $? -ne 0 ]; then
    exit $?
fi
