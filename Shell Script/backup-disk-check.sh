#!/bin/bash

size=`du -s /mnt/oraclebackup/flashback | awk '{print $1}'`
url=(https://hooks.slack.com/services/123456)

if [ "$size" -gt 8388608 ]; then
   payload='
	{
		"text": "*'"$HOSTNAME"' flashback備份空間使用量已達80%*"
	}'
	curl -s -X POST -H "Content-type: application/json" -d "$payload" $url
    	exit 1
else
	break
fi
