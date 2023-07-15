#!/bin/bash
NFS_SERVER_HOSTNAME=$1
if [ -z "$NFS_SERVER_HOSTNAME" ]
then    
    echo "No NFS server supplied"
    exit 1
fi
NFS_SERVER_PATH=$2
if [ -z "$NFS_SERVER_PATH" ]
then    
    echo "No NFS path supplied"
    exit 1
fi
USERNAME=$3
if [ -z "$USERNAME" ]
then    
    echo "No username supplied, using default administrator"
    USERNAME=administrator
fi
# Test if we can connect to the NFS server via the nfs client
apt-get update
apt-get install -y nfs-common
showmount -e $NFS_SERVER_HOSTNAME
if [ $? -ne 0 ]; then
    echo "Could not connect to NFS server $NFS_SERVER_HOSTNAME"
    exit 1
fi

pushd /home/$USERNAME
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.server=$NFS_SERVER_HOSTNAME \
    --set nfs.path=$NFS_SERVER_PATH
kubectl patch storageclass nfs-client -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
popd