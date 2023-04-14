#!/bin/bash
zabbix_agent_path="/opt/zabbix-agent"

#determine zabbix metadata
if [[ "$HOSTNAME" =~ "prd" ]];then
	IDC_ENV=prod
elif [[ "$HOSTNAME" =~ "dev" ]];then
	IDC_ENV=dev
elif [[ "$HOSTNAME" =~ "stg" ]];then
        IDC_ENV=stg
elif [[ "$HOSTNAME" =~ "rel" ]];then
        IDC_ENV=rel
fi

mkdir -p $zabbix_agent_path/volume
cat > $zabbix_agent_path/docker-compose.yml << EOF
version: '3.7'

services:

  zabbix-agent:
    image: zabbix/zabbix-agent:6.0.7-centos
    container_name: zabbix-agent
    network_mode: host
    ports:
      - "10050:10050"
    user: root
    restart: always
    environment:
      - ZBX_SERVER_HOST=172.31.8.106
      - TZ=Asia/Taipei
      - ZBX_HOSTNAME=$HOSTNAME
      - ZBX_METADATA=$IDC_ENV
    volumes:
      - /dev:/dev:ro
EOF

#run docker compose
cd $zabbix_agent_path
docker compose up -d
