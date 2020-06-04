#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

# parse inputs from options
CRON_SCHEDULE=$(jq --raw-output ".schedule" $CONFIG_PATH)

touch /hassio-backup.log
echo "Configuring cron"
echo "${CRON_SCHEDULE} sh -c /backup.sh >> /hassio-backup.log 2>&1"

echo "Starting cron"
crond && tail -f /hassio-backup.log
