#!/bin/bash

if [ $# -ne 2 ]; then
   echo "Syntax error: $0 MANAGER_HOSTNAME MANAGER_IP"
   exit -1
fi

MANAGER_HOSTNAME=$1
MANAGER_IP=$2

if [ ! -f /etc/docker/daemon.json ]; then
  echo "Configurando Docker Daemon (insecure-registries)..."
  mkdir -p /etc/docker >& /dev/null

  cat <<EOF | sudo tee /etc/docker/daemon.json
  {
    "insecure-registries" : [
      "$MANAGER_HOSTNAME:5000",
      "$MANAGER_IP:5000"
    ]
  }
EOF

systemctl restart docker

fi

if [ ! -f /etc/sysctl.d/99-disable-ipv6.conf ]; then
  echo "Desactivando IPv6..."
  echo "net.ipv6.conf.all.disable_ipv6 = 1
  net.ipv6.conf.default.disable_ipv6 = 1
  net.ipv6.conf.lo.disable_ipv6 = 1" | sudo tee /etc/sysctl.d/99-disable-ipv6.conf

  # Aplicar los cambios inmediatamente
  sysctl --system >& /dev/null

  echo "IPv6 desactivado con éxito."
fi
