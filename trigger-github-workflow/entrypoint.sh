#!/bin/bash

set -e

GITHUB_TOKEN=$1
REPO="$2/$3"
REF=$4
WORKFLOW_FILENAME=$5
TEMP_FILE="temp.json"
SLEEP_INTERVAL=30

echo "Invoking workflow of \"$REPO\" repository with workflow file name \"$WORKFLOW_FILENAME\""
data="{\"ref\":\"$REF\"}"
curl \
    --silent \
    --request POST \
    --header "Accept: application/vnd.github.v3+json" \
    --header "Authorization: Bearer $GITHUB_TOKEN" \
    "https://api.github.com/repos/${REPO}/actions/workflows/${WORKFLOW_FILENAME}/dispatches" \
    --data ${data}

if [ $? -eq 6 ]; then
    true
fi

echo "Successfully workflow triggered"

curl \
    --silent \
    --location \
    --request GET \
    --header 'Accept: application/vnd.github.v3+json' \
    --header 'Content-Type: application/json' \
    --header "Authorization: Bearer $GITHUB_TOKEN" \
    --header 'cache-control: no-cache' \
    "https://api.github.com/repos/${REPO}/actions/runs"  > $TEMP_FILE
        
RUN_ID=$(jq -r ".workflow_runs | sort_by( .created_at ) | .[-1] | .id" $TEMP_FILE)

echo "Checking conclusion of the last executed run in \"$REPO\" repository:"
while true; do
 
    curl \
        --silent \
        --location \
        --request GET \
        --header 'Accept: application/vnd.github.v3+json' \
        --header 'Content-Type: application/json' \
        --header "Authorization: Bearer $GITHUB_TOKEN" \
        --header 'cache-control: no-cache' \
        "https://api.github.com/repos/${REPO}/actions/runs/$RUN_ID"  > $TEMP_FILE
    
    JOB_URL=$(jq -r ". | .html_url" $TEMP_FILE)
    STATUS=$(jq -r ". | .status" $TEMP_FILE)
    echo "Checking run state: ${STATUS}"
    echo "Worklflow run url: ${JOB_URL}"
 
    if [ "$STATUS" = "completed" ]; then
        CONCLUSION=$(jq -r ". | .conclusion" $TEMP_FILE)
        echo "Checking run conclusion: ${CONCLUSION}"
        break;
    fi
 
    sleep $SLEEP_INTERVAL
done
rm $TEMP_FILE || true

if [ "$CONCLUSION" != "success" ]; then
    exit 1
fi
