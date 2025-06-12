#!/bin/bash
set -e
NFS_SERVER="192.168.1.100"
NFS_REMOTE_DIR="/export/k3s-data"
LOCAL_MOUNT_DIR="/mnt/k3s"
if ! command -v mount.nfs &>/dev/null; then
    echo "Installing NFS client..."
    if [ -f /etc/debian_version ]; then
        sudo apt update && sudo apt install -y nfs-common
    elif [ -f /etc/redhat-release ]; then
        sudo dnf install -y nfs-utils
    fi
fi
sudo mkdir -p "$LOCAL_MOUNT_DIR"
echo "Mounting NFS share..."
sudo mount -t nfs "$NFS_SERVER:$NFS_REMOTE_DIR" "$LOCAL_MOUNT_DIR"
FSTAB_ENTRY="$NFS_SERVER:$NFS_REMOTE_DIR $LOCAL_MOUNT_DIR nfs defaults 0 0"
if ! grep -qs "$FSTAB_ENTRY" /etc/fstab; then
    echo "Updating /etc/fstab..."
    echo "$FSTAB_ENTRY" | sudo tee -a /etc/fstab
fi

echo "NFS setup complete: $NFS_REMOTE_DIR -> $LOCAL_MOUNT_DIR"

