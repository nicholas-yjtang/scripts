#!/bin/bash
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cluster_hostfile=$CURRENT_DIR/cluster_endpoint_hostfile
cluster_endpoint=$(cat $cluster_hostfile |awk '{print $2}')
if [ -z "$cluster_endpoint" ]; then
    echo "No cluster endpoint found"
    exit 1
fi
kubeadm init --control-plane-endpoint $cluster_endpoint --pod-network-cidr=192.168.0.0/16
if [ ! -f /etc/kubernetes/admin.conf ]; then
    echo "No admin.conf found"
    exit 1
fi
USERNAME=$1
echo "USERNAME=$USERNAME"
if [ -z "$USERNAME" ]; then
    echo "No username was sent to the script, exiting"
    exit 1
fi
mkdir -p /home/$USERNAME/.kube
cp /etc/kubernetes/admin.conf /home/$USERNAME/.kube/config
chown -R $USERNAME:$USERNAME /home/$USERNAME/.kube
# Create the .kube for the root user too for convenience during the installation process
mkdir -p /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config