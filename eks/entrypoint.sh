#!/bin/bash

set -e
KUBE_CONFIG_DATA=$1
KUBECTL_ARG=$2
echo "$KUBE_CONFIG_DATA" | base64 -d > /tmp/config
sh -c "kubectl --kubeconfig /tmp/config $KUBECTL_ARG"
