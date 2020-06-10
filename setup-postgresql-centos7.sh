#!/bin/bash

# Database information
APP_DB_USER=myapp
APP_DB_PASS=myapp
APP_DB_NAME=myapp_db

# PostgreSQL version
PG_VERSION=9.6
IP_ADDRESS=ipaddr=$(hostname -I)
PG_PORT=5432

###########################################################
# Changes below this line are probably not necessary
###########################################################
print_db_usage () {
  echo "PostgreSQL database has been setup, access it from local machine on the forwarded port (default: $PG_PORT)"
  echo "  Hosts: $IP_ADDRESS"
  echo "  Port: $PG_PORT"
  echo "  Database: $APP_DB_NAME"
  echo "  Username: $APP_DB_USER"
  echo "  Password: $APP_DB_PASS"
  echo ""
}


# Update package list and upgrade all packages
yum -y update
yum -y upgrade

rpm -ivh "https://yum.postgresql.org/$PG_VERSION/redhat/rhel-7.3-x86_64/pgdg-redhat-repo-latest.noarch.rpm"
yum -y install postgresql-server postgresql-contrib
postgresql-setup initdb


PG_CONF="/var/lib/pgsql/data/postgresql.conf"
PG_HBA="/var/lib/pgsql/data/pg_hba.conf"


# Edit postgresql.conf to change listen address to '*':
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"

# Append to pg_hba.conf to add password auth:
echo "host    all             all             all                     md5" >> "$PG_HBA"

# Explicitly set default client_encoding
echo "client_encoding = utf8" >> "$PG_CONF"

# Restart so that all new config is loaded:
systemctl start postgresql

cat << EOF | su - postgres -c psql
-- Create the database user:
CREATE USER $APP_DB_USER WITH PASSWORD '$APP_DB_PASS';

-- Create the database:
CREATE DATABASE $APP_DB_NAME WITH OWNER=$APP_DB_USER
                                  LC_COLLATE='en_US.utf8'
                                  LC_CTYPE='en_US.utf8'
                                  ENCODING='UTF8'
                                  TEMPLATE=template0;
EOF




echo "Successfully created PostgreSQL dev virtual machine."
echo ""
print_db_usage


# firewall-cmd --permanent --zone=public --add-port=5432/tcp
# firewall-cmd --reload

systemctl start postgresql
systemctl enable postgresql
systemctl status postgresql