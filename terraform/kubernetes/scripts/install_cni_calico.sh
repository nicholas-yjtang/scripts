#!/bin/bash
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
USERNAME=$1
pushd /home/$USERNAME
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
pushd $CURRENT_DIR
curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml -O
#customize the custom-resources.yaml file while you are here if you find it necessary
popd
kubectl create -f $CURRENT_DIR/custom-resources.yaml
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl get nodes -o wide
popd