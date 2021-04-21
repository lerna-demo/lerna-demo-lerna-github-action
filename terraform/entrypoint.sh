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
    if(( $?==0 ))
    then
        break;
    elif(( $?!=0 && $count>=$RETRY))
    then
        exit 1
    else
        num=$(($count + 1))
        sleep $SLEEP_INTERVAL
        echo "Retrying again"
    fi
done
