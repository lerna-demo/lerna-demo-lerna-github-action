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
        exit 1
    else
        count=$(($count + 1))
        sleep $SLEEP_INTERVAL
        echo "Retrying again"
    fi
done
