#!/bin/bash
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cluster_hostfile=$CURRENT_DIR/cluster_endpoint_hostfile
hostfile=/etc/hosts
cluster_endpoint_ip=$(cat $cluster_hostfile |awk '{print $1}')
cluster_endpoint_hostname=$(cat $cluster_hostfile |awk '{print $2}')    
if [ -z "$cluster_endpoint_ip" ]; then
    echo "No cluster endpoint found"
    exit 1
fi

if grep --quiet $cluster_endpoint_ip $hostfile; then
    echo "cluster_endpoint_ip=$cluster_endpoint_ip"
    sed -i -E "s/($cluster_endpoint_ip.*)$/\1 $cluster_endpoint_hostname/" $hostfile
else
    echo "$cluster_endpoint_ip $cluster_endpoint_hostname" >> $hostfile
fi