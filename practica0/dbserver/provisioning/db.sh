#!/bin/bash

apt update
apt install -y mariadb-server curl vim unzip
systemctl enable mariadb.service
systemctl start mariadb.service

cat <<EOF >> /etc/mysql/my.cnf
[mysqld]
skip-networking=0
skip-bind-address
EOF

mysql -u root < /vagrant/sql/db.sql
DB_NAME=`head -1 /vagrant/sql/db.sql | cut -d ";" -f 1 | cut -d " " -f 6`
systemctl restart mariadb.service
mysql -u root $DB_NAME < /vagrant/sql/addressbook.sql
