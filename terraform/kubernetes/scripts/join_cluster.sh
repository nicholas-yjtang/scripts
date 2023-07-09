#!/bin/bash
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd $CURRENT_DIR
join_command=$(kubeadm token create --print-join-command)
if [ -z "$join_command" ]; then
    echo "No join command found"
    exit 1
fi
admin=$1
if [ -z "$admin" ]; then
    admin="administrator" #default admin user
fi
cat hosts | grep "node" | awk '{print $1}' | while read node;
do
ssh -n -o StrictHostKeyChecking=no -i .ssh/id_rsa $admin@$node "sudo $join_command"
if [ ! -z /etc/kubernetes/admin.conf ]; then
    echo "No admin.conf found"
else
    scp -i .ssh/id_rsa -B /etc/kubernetes/admin.conf $admin@node/.kube/config
fi
done
popd