#!/bin/bash
apt update && apt install -y nfs-kernel-server
mkfs -t ext4 /dev/vdb
NFS_PATH=$1 # /mnt/nfs/kubedata
if [ -z "$NFS_PATH" ]; then
    echo "No NFS path supplied"
    exit 1
fi
#split path into last diretory and remainder
NFS_MOUNT_POINT=$(echo $NFS_PATH | rev | cut -d'/' -f2- | rev) # /mnt/nfs
NFS_EXPORT_PATH=$(echo $NFS_PATH | rev | cut -d'/' -f1 | rev) # kubedata

if [ -z "$NFS_MOUNT_POINT" ]; then
    echo "No NFS mount point supplied"
    exit 1
fi
if [ -z "$NFS_EXPORT_PATH" ]; then
    echo "No NFS export path supplied"
    exit 1
fi

if grep --quiet "/dev/vdb" /etc/fstab; then
    echo "NFS disk already in fstab"
else
    echo "/dev/vdb $NFS_MOUNT_POINT ext4 defaults 0 0" >> /etc/fstab
fi

if [ -d $NFS_MOUNT_POINT ]; then
    umount $NFS_MOUNT_POINT
    rm -rf $NFS_MOUNT_POINT
fi
mkdir -p $NFS_MOUNT_POINT
mount $NFS_MOUNT_POINT
mkdir -p $NFS_PATH
chmod -R 777 $NFS_PATH
if grep --quiet "$NFS_PATH" /etc/exports; then
    echo "NFS already exported"
else
    echo "$NFS_PATH *(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
fi
exportfs -a
systemctl restart nfs-kernel-server