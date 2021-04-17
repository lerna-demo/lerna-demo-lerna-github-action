#!/bin/bash

set -e
SSM_PARAMETER_KEY=$1
SSM_PARAMETER_VALUE=$(aws ssm get-parameters --names "$SSM_PARAMETER_KEY" --query 'Parameters[0].Value' --output text)
echo "::set-output name=ssm-parameter-value::$SSM_PARAMETER_VALUE"