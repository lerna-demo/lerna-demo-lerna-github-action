#!/bin/bash

DB_NAME=$1
DB_DESIRED_STATE=$2
RAISE_ERROR_IF_DB_NOT_EXISTS=$3
SLEEP_INTERVAL=30

if [ $DB_DESIRED_STATE == "available" ]; then
    DB_ACTION="start"
    DB_CURRENT_STATE="stopped"
elif [ $DB_DESIRED_STATE == "stopped" ]; then
    DB_ACTION="stop"
    DB_CURRENT_STATE="available"
else
    echo "Wrong State chosen. Valid are available or stopped"
    exit
fi

DB_STATE=$(aws rds describe-db-instances --db-instance-identifier $DB_NAME --query 'DBInstances[0].DBInstanceStatus' --output text)

if [ $? -eq 0 ]; then
    if [ "$DB_STATE" == "$DB_CURRENT_STATE" ]; then
        echo "Making database $DB_DESIRED_STATE ..."
        aws rds $DB_ACTION-db-instance --db-instance-identifier $DB_NAME
    else
        echo "Database need to be in state \"$DB_CURRENT_STATE\" to \"$DB_ACTION\""
        exit
    fi

    while true; do
        DB_STATE=$(aws rds describe-db-instances --db-instance-identifier $DB_NAME --query 'DBInstances[0].DBInstanceStatus' --output text)
        echo "Database current state is \"$DB_STATE\" ..."
        echo $DB_DESIRED_STATE
        if [ "$DB_STATE" == "$DB_DESIRED_STATE" ]; then
            break;
        fi

        sleep $SLEEP_INTERVAL
    done
else
    echo "No DB exists with name \"$DB_NAME\""
    if $RAISE_ERROR_IF_DB_NOT_EXISTS; then
        exit 1;
    fi
fi


