#!/bin/bash

set -e
WORKDIR=$1
TF_WORKSPACE=$2

cd $WORKDIR
terraform init
terraform validate
terraform workspace select -or-create $TF_WORKSPACE
terraform apply -auto-approve
