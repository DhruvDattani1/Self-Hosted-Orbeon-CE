#!/bin/bash
set -e
POOL_NAME="rpool"
ZFS_ROOT="${POOL_NAME}/k3s-data"
EXPORT_PATH="/export/k3s-data"
NFS_EXPORT_LINE="$EXPORT_PATH  *(rw,sync,no_subtree_check,no_root_squash)"
if ! zfs list "$ZFS_ROOT" >/dev/null 2>&1; then
    echo "[+] Creating dataset $ZFS_ROOT..."
    zfs create "$ZFS_ROOT"
fi
echo "[+] Setting root mountpoint to $EXPORT_PATH"
zfs set mountpoint=$EXPORT_PATH $ZFS_ROOT
for dataset in minio orbeon postgres pv; do
    DS="$ZFS_ROOT/$dataset"
    if ! zfs list "$DS" >/dev/null 2>&1; then
        echo "[+] Creating dataset $DS..."
        zfs create "$DS"
    fi
    echo "[+] Inheriting mountpoint for $DS"
    zfs inherit mountpoint "$DS"
done
echo "[+] Creating export directory structure..."
mkdir -p $EXPORT_PATH/{minio,orbeon,postgres,pv}
echo "[+] Setting NFS permissions..."
chown -R nobody:nogroup $EXPORT_PATH
chmod -R 777 $EXPORT_PATH
echo "[+] Installing NFS server..."
apt update
DEBIAN_FRONTEND=noninteractive apt install -y nfs-kernel-server
echo "[+] Configuring /etc/exports..."
grep -q "$EXPORT_PATH" /etc/exports || echo "$NFS_EXPORT_LINE" >> /etc/exports
echo "[+] Reloading exports..."
exportfs -ra
echo "[+] Starting NFS services..."
systemctl enable --now nfs-server rpcbind
echo "[✓] ZFS datasets + NFS export configured at $EXPORT_PATH"
