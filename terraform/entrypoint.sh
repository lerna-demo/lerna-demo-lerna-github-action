#!/bin/bash

WORKDIR=$1
TF_WORKSPACE=$2
TF_ARGS=$3
RETRY=$4
SLEEP_INTERVAL=30

cd $WORKDIR
terraform init
terraform validate
terraform workspace select $TF_WORKSPACE || terraform workspace new $TF_WORKSPACE

count=1
while true; do
    terraform $TF_ARGS
    CMD_EXIT_STATUS=$?
    if(( $CMD_EXIT_STATUS==0 ))
    then
        break;
    elif(( $CMD_EXIT_STATUS!=0 && $count>=$RETRY))
    then
        # Work around for known issue https://registry.terraform.io/modules/Young-ook/eks/aws/1.4.3#unauthorized
        [ $(terraform state list) == "module.eks.kubernetes_config_map.aws_auth[0]" ]
        
        REMAINING_STATE_COUNT=$(terraform state list | wc -l |  awk '{ print $1 }')
        if(( $REMAINING_STATE_COUNT==1 ))
        then
            REMAINING_STATE=$(terraform state list)
            echo "Remaining State"
            echo "$REMAINING_STATE"
            AWS_AUTH_TF_RESOURCE="module.eks.kubernetes_config_map.aws_auth[0]"
            if [ "$REMAINING_STATE" == "$AWS_AUTH_TF_RESOURCE" ]; then
                echo "Deleting \"$AWS_AUTH_TF_RESOURCE\" from TF state"
                terraform state rm $AWS_AUTH_TF_RESOURCE
            else
                exit 1    
            fi    
        else
            exit 1
        fi
    else
        count=$(($count + 1))
        sleep $SLEEP_INTERVAL
        echo "Retrying again"
    fi
done
