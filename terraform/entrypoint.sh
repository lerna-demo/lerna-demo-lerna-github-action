#!/bin/bash

set -e
WORKDIR=$1
TF_WORKSPACE=$2
TF_ARGS=$3

cd $WORKDIR
terraform init
terraform validate
terraform workspace select $TF_WORKSPACE || terraform workspace new $TF_WORKSPACE
terraform $TF_ARGS
