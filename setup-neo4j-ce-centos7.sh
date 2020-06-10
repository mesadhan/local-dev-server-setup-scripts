#!/bin/bash

rpm --import https://debian.neo4j.com/neotechnology.gpg.key

cat >>/etc/yum.repos.d/neo4j.repo<<EOF
[neo4j]
name=Neo4j Yum Repo
baseurl=http://yum.neo4j.com/stable
enabled=1
gpgcheck=1
EOF

yum -y install neo4j



firewall-cmd --zone=public --permanent --add-port=7474/tcp
firewall-cmd --zone=public --permanent --add-port=7473/tcp
firewall-cmd --zone=public --permanent --add-port=7687/tcp
firewall-cmd --zone=public --permanent --add-port=6362/tcp
firewall-cmd --reload
systemctl restart firewalld # if needed
systemctl enable firewalld # if not already set



sudo systemctl start neo4j
sudo systemctl restart neo4j
sudo systemctl enable neo4j
sudo systemctl status neo4j