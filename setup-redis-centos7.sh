#!/bin/bash

sudo yum -y install epel-release yum-utils
sudo yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
sudo yum-config-manager --enable remi

sudo yum -y install redis



#IP_ADDRESS=$(hostname -I|awk '{print $1}')
IP_ADDRESS=$(hostname -I)


# Edit redis.conf to change listen address to '*':
REDIS_CONF="/etc/redis.conf"
sed -i "/^bind 127.0.0.1/ s/$/ $IP_ADDRESS/" "$REDIS_CONF"



sudo systemctl start redis
sudo systemctl enable redis
sudo systemctl status redis


# Lising port view for redis
ss -an | grep 6379

# request in local machine
redis-cli ping
echo "Redis server from your remote machine"
redis-cli -h $(hostname -I|awk '{print $1}') ping



# Expos port so outbound accessable
#sudo firewall-cmd --new-zone=redis --permanent
#sudo firewall-cmd --zone=redis --add-port=6379/tcp --permanent
#sudo firewall-cmd --zone=redis --add-source=192.168.121.0/24 --permanent
#sudo firewall-cmd --reload

echo "Redis Install Successfully"