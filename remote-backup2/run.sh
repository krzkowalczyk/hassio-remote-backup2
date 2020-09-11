#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

# parse inputs from options
CRON_SCHEDULE=$(jq --raw-output ".schedule" $CONFIG_PATH)

touch /hassio-backup.log
echo '''
8888888b.                                 888                 888888b.                     888                                       .d8888b.  
888   Y88b                                888                 888  "88b                    888                                      d88P  Y88b 
888    888                                888                 888  .88P                    888                                             888 
888   d88P .d88b.  88888b.d88b.   .d88b.  888888 .d88b.       8888888K.   8888b.   .d8888b 888  888 888  888 88888b.       888  888      .d88P 
8888888P" d8P  Y8b 888 "888 "88b d88""88b 888   d8P  Y8b      888  "Y88b     "88b d88P"    888 .88P 888  888 888 "88b      888  888  .od888P"  
888 T88b  88888888 888  888  888 888  888 888   88888888      888    888 .d888888 888      888888K  888  888 888  888      Y88  88P d88P"      
888  T88b Y8b.     888  888  888 Y88..88P Y88b. Y8b.          888   d88P 888  888 Y88b.    888 "88b Y88b 888 888 d88P       Y8bd8P  888"       
888   T88b "Y8888  888  888  888  "Y88P"   "Y888 "Y8888       8888888P"  "Y888888  "Y8888P 888  888  "Y88888 88888P"         Y88P   888888888  
                                                                                                             888                               
                                                                                                             888                               
                                                                                                             888                               
'''
echo "Version:${BUILD_VERSION}"
echo '=============================================================================================================================================='
echo "Configuring cron"
echo "${CRON_SCHEDULE} sh -c /backup.sh >> /hassio-backup.log 2>&1" >> /etc/crontabs/root

echo "Current cron config:"
cat /etc/crontabs/root

echo "Starting cron"
crond && tail -f /hassio-backup.log
