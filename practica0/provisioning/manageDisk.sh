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

# Paso 1. Detectar el disco del SO (root)
# 'findmnt /' nos da la partición (ej. /dev/sda1)
# 'lsblk -no pkname' nos da el disco padre de esa partición (ej. sda)
ROOT_DISK=$(lsblk -no pkname $(findmnt -n -o SOURCE /))
echo "El disco del sistema operativo es: /dev/$ROOT_DISK"

# Paso 2. Buscar el disco adicional (Cualquier sdX o vdX que NO sea el ROOT_DISK)
# Listamos solo discos (-d), sin encabezados (-n), solo el nombre (-o NAME)
TARGET_DISK=""
for disk in $(lsblk -dno NAME | grep '^[sv]d'); do
   if [ "$disk" != "$ROOT_DISK" ]; then
       TARGET_DISK="/dev/$disk"
        break
   fi
done

if [ -z "$TARGET_DISK" ]; then
    echo "ERROR: No se encontró un disco adicional."
    exit 1
fi

echo "Disco adicional detectado: $TARGET_DISK"

# Paso 3. Configuración del montaje en fstab usando el UUID
# Añadir a /etc/fstab si no existe para que persista tras reiniciar
if ! grep -q "$MOUNT_POINT" /etc/fstab; then
    # Obtener el UUID
    UUID=$(lsblk -no UUID $TARGET_DISK)

    if [ -z "$UUID" ]; then
        echo "No se pudo encontrar el UUID para $TARGET_DISK (sin formato?)"
    else
        echo "Configurando montaje automático en fstab de $TARGET_DISK (UUID=$UUID)..."
        echo "UUID=$UUID $MOUNT_POINT ext4 defaults,nofail 0 0" >> /etc/fstab
    fi
else
    echo "El UUID ya está configurado en /etc/fstab."
fi

# Paso 4. Formatear el disco 
#  Comprobar si ya tiene formato para evitar errores o borrar datos
# 'blkid' devuelve 0 si hay sistema de archivos, 2 si no lo hay.
if blkid "$TARGET_DISK"; then
    echo "El disco $TARGET_DISK ya tiene formato. Saltando mkfs."
else
    echo "Formateando $TARGET_DISK..."
    mkfs.ext4 "$TARGET_DISK"
fi

# Paso 5. Montar el disco en su punto de montaje
# Comprobar si ya está montado
if grep -qs "$TARGET_DISK" /proc/mounts; then
    echo "El disco $TARGET_DISK ya está montado. Saltando mount."
else
    echo "Montando $TARGET_DISK en $MOUNT_POINT"
    mount "$TARGET_DISK" "$MOUNT_POINT"
fi

#  Paso 6. Listar los sistemas de ficheros
df -h
