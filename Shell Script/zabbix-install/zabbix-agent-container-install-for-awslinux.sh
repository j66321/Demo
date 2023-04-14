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
    yum update -y
    amazon-linux-extras install docker -y
    service docker start
    systemctl enable docker
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
    volumes:
      - /dev:/dev:ro
EOF

#run docker compose
cd $zabbix_agent_path
docker-compose up -d
