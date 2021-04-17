#!/bin/bash

set -e
WORKDIR=$1
TF_ARG=$2
cd $WORKDIR
sh -c "terraform $TF_ARG"
