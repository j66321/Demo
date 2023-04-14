#!/bin/bash
today=`date +%s`

jira_expiracy=`curl -H "Authorization: Bearer 123456" https://jira.1234.cc/rest/plugins/applications/1.0/installed/jira-software/license |jq .expiryDate|cut -c 1-10`
jira_compare=`expr $jira_expiracy - $today`
jira_diffCount=`expr $jira_compare / 86400`


confluence_expiracy=`curl -H "Authorization: Bearer 123456" https://confluence.1234.cc/rest/license/1.0/license/details | jq .expiryDate|cut -c 1-10`
confluence_compare=`expr $confluence_expiracy - $today`
confluence_diffCount=`expr $confluence_compare / 86400`

if [ $jira_diffCount -lt 1 ];
then
    cat << EOF > /opt/zabbix-agent/volume/jira_confluence_monitor/jira_expiracy.txt
1
EOF
elif [ $jira_diffCount -lt 3 ];
then
    cat << EOF > /opt/zabbix-agent/volume/jira_confluence_monitor/jira_expiracy.txt
3
EOF
else
    cat << EOF > /opt/zabbix-agent/volume/jira_confluence_monitor/jira_expiracy.txt
0
EOF
fi

if [ $confluence_diffCount -lt 1 ];
then
    cat << EOF > /opt/zabbix-agent/volume/jira_confluence_monitor/confluence_expiracy.txt
1
EOF
elif [ $jira_diffCount -lt 3 ];
then
    cat << EOF > /opt/zabbix-agent/volume/jira_confluence_monitor/jira_expiracy.txt
3
EOF
else
    cat << EOF > /opt/zabbix-agent/volume/jira_confluence_monitor/confluence_expiracy.txt
0
EOF
fi
