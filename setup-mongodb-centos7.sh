#!/bin/bash

cat >>/etc/yum.repos.d/mongodb-org.repo<<EOF
[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc
EOF

sudo yum install -y mongodb-org


sudo systemctl start mongod
sudo systemctl enable mongod
sudo systemctl status mongod

# mongo
# db.version()


# https://linuxize.com/post/how-to-install-mongodb-on-centos-7/