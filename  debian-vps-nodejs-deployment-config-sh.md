

Open `vi deployment_config.sh`, include


```bash
#!/bin/bash

ENV_APP_DB_USER="$(cut -d'=' -f 2 <<< "$1")"
ENV_APP_DB_PASS="$(cut -d'=' -f 2 <<< "$2")"
ENV_APP_DB_NAME="$(cut -d'=' -f 2 <<< "$3")"
#ENV_APP_DB_SQL_PATH="$(cut -d'=' -f 2 <<< "$4")"

APP_DOMAIN_NAME="$(cut -d'=' -f 2 <<< "$4")"    # example.com
APP_RUNNING_PORT="$(cut -d'=' -f 2 <<< "$5")"   # 8080

if [ -z "$APP_DOMAIN_NAME" -a "$APP_DOMAIN_NAME" == " " ]; then
  #echo "Str is not null or space"
  APP_DOMAIN_NAME="example.com"
fi
if [ -z "$APP_RUNNING_PORT" -a "$APP_RUNNING_PORT" == " " ]; then
  #echo "Str is not null or space"
  APP_RUNNING_PORT="80808"
fi

echo "App Domain: $APP_DOMAIN_NAME"
echo "App Running Port: $APP_RUNNING_PORT"


echo "NodeJs Installation start..."

sudo apt-get -y update
sudo apt-get -y upgrade

sudo apt-get -y install curl dirmngr apt-transport-https lsb-release ca-certificates
sudo apt-get -y install gcc g++ make
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash

sudo apt-get -y update
sudo apt-get -y install nodejs

node --version
npm --version

echo "NodeJS Instllation done.!"


echo "NGINX installation start.!"
sudo apt-get -y install nginx

systemctl start nginx
systemctl enable nginx
systemctl status nginx

#echo "Enable Ports so that we can aceess"


echo "NGINX Installtion done."
echo "Get Installation start...."
sudo apt-get -y install git



echo "PostgreSQL Installation start...."

# Database information
APP_DB_USER="$ENV_APP_DB_USER"
APP_DB_PASS="$ENV_APP_DB_PASS"
APP_DB_NAME="$ENV_APP_DB_NAME"

# PostgreSQL version
#PG_VERSION=9.4
PG_VERSION=10
IP_ADDRESS="localhost"
PG_PORT=5432


print_db_usage () {
  echo "PostgreSQL database has been setup, access it from local machine on the forwarded port (default: $PG_PORT)"
  echo "  Hosts: $IP_ADDRESS"
  echo "  Port: $PG_PORT"
  echo "  Database: $APP_DB_NAME"
  echo "  Username: $APP_DB_USER"
  echo "  Password: $APP_DB_PASS"
  echo ""
}

PG_REPO_APT_SOURCE=/etc/apt/sources.list.d/pgdg.list
if [ ! -f "$PG_REPO_APT_SOURCE" ]
then
  # Add PG apt repo:
  echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > "$PG_REPO_APT_SOURCE"

  # Add PGDG repo key:
  wget --quiet -O - https://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -
fi

# Update package list and upgrade all packages
apt-get -y update
apt-get -y upgrade

apt-get -y install "postgresql-$PG_VERSION" "postgresql-contrib-$PG_VERSION"

PG_CONF="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
PG_HBA="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"
PG_DIR="/var/lib/postgresql/$PG_VERSION/main"

# Edit postgresql.conf to change listen address to '*':
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"

# Append to pg_hba.conf to add password auth:
echo "host    all             all             all                     md5" >> "$PG_HBA"

# Explicitly set default client_encoding
echo "client_encoding = utf8" >> "$PG_CONF"

# Restart so that all new config is loaded:
service postgresql restart

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



echo ""
print_db_usage

systemctl start postgresql
systemctl enable postgresql
systemctl status postgresql

echo "PostgreSQL Installation done."


## pm2 setup for nodejs service runner

npm install pm2@latest -g
sudo pm2 startup systemd
pm2 save

cd ~


nginx_path="/etc/nginx/conf.d/${APP_RUNNING_PORT}.conf"

cat >>"$nginx_path"<<EOF
server {
    listen 80;
    server_name ${APP_DOMAIN_NAME} www.${APP_DOMAIN_NAME};

    location / {
        proxy_pass http://localhost:${APP_RUNNING_PORT};
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

sudo systemctl restart nginx
cat $nginx_path


echo "######################### Configuration Done. Follow Rest Guideline ################################"
```








## ------------------- Post Installation -------------------

#### 1. Configure host machine

```bash
bash <(curl -s https://gist.githubusercontent.com/mesadhan/d873bf262238deb674aa7b7a9d72fc38/raw/96c1dc1f0e8317b174e4e785b23a2dbc23f15f17/debian-vps-nodejs-deployment-config-sh) \
ENV_APP_DB_USER="myapp" \
ENV_APP_DB_PASS="myapp" \
ENV_APP_DB_ENV="myapp_db" \
APP_DOMAIN_NAME="subdomain.example.com" \
APP_RUNNING_PORT="8080"
```

### 2. Setup project

```
Example1: Access Url: example.com.       pointed-to-> localhost:8080
Example2: Access Url: example.com/app2   pointed-to-> localhost:8081
```

Step 1:

Open `vi /etc/nginx/conf.d/subdomain.example.com.conf`, and append below configuration

```
server {
    listen 80;
    server_name subdomain.example.com www.subdomain.example.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
    
    location /app2 {
       proxy_pass http://localhost:8081;
    }
}
```

Step 2:

```
cd /var/www
git clone project_source_url

sudo nginx -t
sudo systemctl restart nginx

sudo -u postgres psql -h localhost -p 5432 -U myapp -d myapp_db < project_source_url/database/database.sql
pm2 start index.js
pm2 list
```

Done!