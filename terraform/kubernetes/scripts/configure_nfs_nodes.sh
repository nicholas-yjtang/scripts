#!/bin/bash
apt update && apt install -y nfs-common
NFS_SERVER_HOSTNAME=$1
if [ -z "$NFS_SERVER_HOSTNAME" ]
then    
    echo "No NFS server supplied"
    exit 1
fi

showmount -e $NFS_SERVER_HOSTNAME
if [ $? -ne 0 ]; then
    echo "Could not connect to NFS server $NFS_SERVER_HOSTNAME"
    exit 1
fi