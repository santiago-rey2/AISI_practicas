#!/bin/bash

# Paso 1: instalación de otros paquetes necesarios
# Nota: Se añade ca-certificates y curl, necesarios para descargar la clave en el paso 2
sudo apt-get update
sudo apt-get install -y lynx gnupg lsb-release ca-certificates curl

# Paso 2: Descargar la clave de Docker y añadir 
# el repositorio a las fuentes de APT
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt-get update

# Paso 3: instalación de los paquetes de Docker
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Paso 4: creación del grupo docker
# Usamos -f o || true para evitar error si el grupo ya fue creado por la instalación del paquete en el paso 3
sudo groupadd -f docker

# Paso 5: añadir el usuario actual (vagrant) al
# grupo docker
sudo /usr/sbin/usermod -aG docker ${USER}

# Paso 6: desactivamos IPv6 para evitar problemas con Docker Swarm
echo "net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1" | sudo tee /etc/sysctl.d/99-disable-ipv6.conf