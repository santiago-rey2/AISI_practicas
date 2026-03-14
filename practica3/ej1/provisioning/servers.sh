#!/bin/bash

dnf -y install python3-setuptools wget curl vim nano lynx

# Copy ssh public key
SSH_PUBLIC_KEY=/vagrant/provisioning/id_rsa.pub
USER_DIR=/home/vagrant/.ssh

if [ ! -f $SSH_PUBLIC_KEY ]; then
	echo "SSH public key does not exist"
	exit -1
fi

sed -i "/-aisi/d" $USER_DIR/authorized_keys >& /dev/null
cat $SSH_PUBLIC_KEY >> $USER_DIR/authorized_keys
chown vagrant:vagrant $USER_DIR/authorized_keys
chmod 0600 $USER_DIR/authorized_keys

# Configure firewalld for webapp server
if [[ "$HOSTNAME" == *"-web" ]]; then
	firewall-cmd --permanent --add-service=http
fi

# Configure firewalld for database server
if [[ "$HOSTNAME" == *"-db" ]]; then
	firewall-cmd --permanent --add-port=3306/tcp
fi

firewall-cmd --reload
