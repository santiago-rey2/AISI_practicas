#!/bin/bash

if [ $# -ne 1 ]; then
   echo "Syntax error: $0 MOUNT_POINT"
   exit -1
fi

MOUNT_POINT=$1

# Comprobar si el punto de montaje existe
if [ ! -d "$MOUNT_POINT" ]; then
    echo "El punto de montaje $MOUNT_POINT no existe"
    exit -1
fi

DATABASE=`basename $MOUNT_POINT`
FILE=$MOUNT_POINT/info
INDEX=/var/www/html/index.php

apt update
apt-get -y install curl vim unzip lynx lshw
chown -R vagrant:vagrant $MOUNT_POINT
echo "CREATE DATABASE IF NOT EXISTS $DATABASE;" > /vagrant/dbserver/sql/db.sql

. /etc/os-release
uname -nrspv > $FILE
echo "$NAME $VERSION" >> $FILE
id >> $FILE
date >> $FILE
lsblk >> $FILE
lshw -class storage -short >> $FILE

if [ -f "$FILE" ]; then
	cat $INDEX >> $FILE
else
	echo "$INDEX not found!" >> $FILE
fi
