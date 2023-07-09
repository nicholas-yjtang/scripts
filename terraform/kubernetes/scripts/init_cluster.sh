#!/bin/bash
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cluster_hostfile=$CURRENT_DIR/cluster_endpoint_hostfile
cluster_endpoint=$(cat $cluster_hostfile |awk '{print $2}')
if [ -z "$cluster_endpoint" ]; then
    echo "No cluster endpoint found"
    exit 1
fi
kubeadm init --control-plane-endpoint $cluster_endpoint --pod-network-cidr=192.168.0.0/16
pushd $CURRENT_DIR
if [ ! -f /etc/kubernetes/admin.conf ]; then
    echo "No admin.conf found"
    exit 1
fi
mkdir -p .kube
cp /etc/kubernetes/admin.conf .kube/config
USERNAME=$(echo $CURRENT_DIR | awk -F/ '{print $3}')
chown $USERNAME:$USERNAME .kube/config
popd