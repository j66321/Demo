#!/bin/bash
zabbix_agent_path="/opt/zabbix-agent"

#determine zabbix metadata
if [[ "$HOSTNAME" =~ "dev" ]] || [[ "$HOSTNAME" =~ "Dev" ]] || [[ "$HOSTNAME" =~ "DEV" ]];then
	IDC_ENV=dev
elif [[ "$HOSTNAME" =~ "prod" ]];then
        IDC_ENV=prod
else 
        IDC_ENV=common
fi

#determine whether to install docker service or not
if [[ `systemctl is-active docker` = "unknown" ]];then
    apt-get update
    apt-get install ca-certificates curl gnupg lsb-release
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
else 
    echo "docker service is installed"
fi

#import zabbix agent docker compose and volume
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
EOF

#run docker compose
cd $zabbix_agent_path
docker-compose up -d
