#!/bin/bash
apt update && apt install -y apt-transport-https ca-certificates curl
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
VERSION=$1
if [ -z "$VERSION" ]; then
    VERSION=1.27.0-00
fi
apt update && apt install -y kubelet=$VERSION kubeadm=$VERSION kubectl=$VERSION
apt-mark hold kubelet kubeadm kubectl
USERNAME=$2
if [ -z "$USERNAME" ]; then
    echo "No username was sent to the script, exiting"
    exit 1
fi
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
mkdir -p /home/$USERNAME/.kube
mkdir -p /root/.kube
chown $USERNAME:$USERNAME /home/$USERNAME/.kube