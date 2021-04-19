#!/bin/bash

set -e
KUBE_CONFIG_DATA=$1
KUBECTL_ARG=$2
APP_HOST=$3
APP_NAME=$4
APP_ENVIRONMENT=$5

echo "$KUBE_CONFIG_DATA" | base64 -d > /tmp/config

if [ "$KUBECTL_ARG" != "" ]; then
    sh -c "kubectl --kubeconfig /tmp/config $KUBECTL_ARG"
elif [ "$APP_HOST" != "" ]; then
    POD_ID=$(kubectl --kubeconfig /tmp/config get pods -l name=$APP_NAME -n $APP_ENVIRONMENT | tail -1 | awk '{print $1}')
    HTTP_STATUS=kubectl --kubeconfig /tmp/config exec $POD_ID -n $APP_ENVIRONMENT -- curl -o /dev/null -s -w "%{http_code}\n" $APP_HOST
    if [ "$HTTP_STATUS" != "200" ]; then
        echo "Application is not healthy, HTTP STATUS CODE = \"$HTTP_STATUS\""
        exit 1
    fi
fi

