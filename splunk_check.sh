#!/bin/bash

# This script ensures no unauthorized changes are made to the Splunk config.
# See https://kb/splunk for more info.

# define variables
SLACK_WEBHOOK_URL=${SLACK_WEBHOOK_URL:-"MISSING_WEBHOOK"}
config_file="/opt/splunk/etc/system/local/config.conf"
hash_file="/opt/splunk/etc/system/local/config.conf.md5"

# compare current file to hash
md5sum -c "$hash_file" > /dev/null 2>&1
status=$? #capture exit code

# function to send alerts to slack

send_slack_alert() {
    local message="$1"
    local payload="{\"text\": \"$message\"}"

if [[ -z "$SLACK_WEBHOOK_URL" || "$SLACK_WEBHOOK_URL" == "MISSING_WEBHOOK" ]]; then
echo "ERROR: Slack webhook is not set!" >&2
return 1
fi
 
    curl -X POST -H 'Content-type: application/json' --data "$payload" "$SLACK_WEBHOOK_URL"
}

# alert only if status is not "OK"
if [[ $status -ne 0 ]]; then
	echo "ALERT: Integrity check failed! Status: $status"
	send_slack_alert "*ALERT:* Integrity check failed on *$config_file*! Exit status: $status."
else
	echo "Config file unchanged."
fi
	



