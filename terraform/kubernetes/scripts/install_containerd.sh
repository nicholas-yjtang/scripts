#!/bin/bash
#install containerd
wget -O containerd-1.7.2-linux-amd64.tar.gz https://github.com/containerd/containerd/releases/download/v1.7.2/containerd-1.7.2-linux-amd64.tar.gz
tar -xvf containerd-1.7.2-linux-amd64.tar.gz -C /usr/local
wget -O containerd.service https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
mv containerd.service /etc/systemd/system/containerd.service
systemctl daemon-reload
systemctl enable --now container
#install runc
wget -O runc.amd64 https://github.com/opencontainers/runc/releases/download/v1.1.7/runc.amd64
install -m 755 runc.amd64 /usr/local/sbin/runc
mkdir -p /etc/containerd/
systemctl restart containerd
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd $CURRENT_DIR
./install_containerd_cni.sh
popd