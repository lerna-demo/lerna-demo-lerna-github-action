#!/bin/bash

GITHUB_TOKEN=$1
REPO="$2/$3"
REF=$4
WORKFLOW_FILENAME=$5
TEMP_FILE="temp.json"
SLEEP_INTERVAL=30

trigger_workflow () {
  echo "Invoking workflow of \"$REPO\" repository with workflow file name \"$WORKFLOW_FILENAME\""
  data="{\"ref\":\"$REF\"}"
  curl \
    --silent \
    --request POST \
    --header "Accept: application/vnd.github.v3+json" \
    --header "Authorization: Bearer $GITHUB_TOKEN" \
    "https://api.github.com/repos/${REPO}/actions/workflows/${WORKFLOW_FILENAME}/dispatches" \
    --data ${data}
  echo "Successfully workflow triggered"
}

list_workflow_runs () {
    curl \
        --silent \
        --location \
        --request GET \
        --header 'Accept: application/vnd.github.v3+json' \
        --header 'Content-Type: application/json' \
        --header "Authorization: Bearer $GITHUB_TOKEN" \
        --header 'cache-control: no-cache' \
        "https://api.github.com/repos/${REPO}/actions/runs"  > $TEMP_FILE
}

workflow_run_status () {
    curl \
        --silent \
        --location \
        --request GET \
        --header 'Accept: application/vnd.github.v3+json' \
        --header 'Content-Type: application/json' \
        --header "Authorization: Bearer $GITHUB_TOKEN" \
        --header 'cache-control: no-cache' \
        "https://api.github.com/repos/${REPO}/actions/runs/$RUN_ID"  > $TEMP_FILE
}

list_workflow_runs
BEFORE_RUN_NUMBER=$(jq -r ".workflow_runs | sort_by( .created_at ) | .[-1] | .run_number" $TEMP_FILE)

trigger_workflow

while true; do
    list_workflow_runs

    count=$(jq -r ".total_count " $TEMP_FILE)
 
    if [ $count -ne 0 ]; then
        RUN_NUMBER=$(jq -r ".workflow_runs | sort_by( .created_at ) | .[-1] | .run_number" $TEMP_FILE)
        if [ $RUN_NUMBER -ne $BEFORE_RUN_NUMBER ]; then
            break;
        fi
    fi

    sleep $SLEEP_INTERVAL
done

echo "Run Number: $RUN_NUMBER"
RUN_ID=$(jq -r ".workflow_runs | sort_by( .created_at ) | .[-1] | .id" $TEMP_FILE)
echo "Run ID: $RUN_ID"
echo "Checking conclusion of the last executed run in \"$REPO\" repository:"
while true; do
    workflow_run_status
    
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
