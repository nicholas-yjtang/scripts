#!/bin/bash
cluster_hostfile="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/cluster_endpoint_hostfile"
cluster_endpoint=$(cat $cluster_hostfile |awk '{print $1}')
if [ -z "$cluster_endpoint" ]; then
    echo "No cluster endpoint found"
    exit 1
fi
kubeadm init --control-plane-endpoint $cluster_endpoint