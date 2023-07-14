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
cat hosts | grep "node" | awk '{print $2}' | while read node;
do
if [ ! -f /etc/kubernetes/admin.conf ]; then
    echo "No admin.conf found"
else
    scp -i .ssh/id_rsa -B /etc/kubernetes/admin.conf $admin@$node:/home/$admin/.kube/config
fi
ssh -n -o StrictHostKeyChecking=no -i .ssh/id_rsa $admin@$node "/opt/k8setup/wait.sh; sudo $join_command;"
done
cat hosts | grep "control" | awk '{print $2}' | while read node;
do
pushd /home/$admin
kubectl taint nodes $node node-role.kubernetes.io/control-plane:NoSchedule-
popd
done
popd