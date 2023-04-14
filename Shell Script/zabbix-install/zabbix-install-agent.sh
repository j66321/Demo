#!/bin/bash

if [[ "$HOSTNAME" =~ "oracle" ]];then
	IDC_ENV=oracle
elif [[ "$HOSTNAME" =~ "dev" ]];then
	IDC_ENV=dev
elif [[ "$HOSTNAME" =~ "stg" ]];then
        IDC_ENV=stg
elif [[ "$HOSTNAME" =~ "stage" ]];then
        IDC_ENV=stg
elif [[ "$HOSTNAME" =~ "rel" ]];then
        IDC_ENV=rel
elif [[ "$HOSTNAME" =~ "cache" ]];then
        IDC_ENV=cache
else 
        IDC_ENV=dev-ops
fi

rpm -Uvh https://repo.zabbix.com/zabbix/6.0/rhel/$(rpm -E %{rhel})/x86_64/zabbix-release-6.0-1.el$(rpm -E %{rhel}).noarch.rpm
yum -y install zabbix-agent

cat > /etc/zabbix/zabbix_agentd.conf << EOF
PidFile=/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=0
Server=10.1.7.242
ServerActive=10.1.7.242
Hostname=$HOSTNAME
HostnameItem=system.hostname
HostMetadata=$IDC_ENV
Include=/etc/zabbix/zabbix_agentd.d/*.conf
EOF

systemctl start zabbix-agent
systemctl enable zabbix-agent
