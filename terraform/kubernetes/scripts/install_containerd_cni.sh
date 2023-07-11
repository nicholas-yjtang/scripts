#!/bin/bash
#install cni
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd $CURRENT_DIR
wget -O cni-plugins-linux-amd64-v1.3.0.tgz https://github.com/containernetworking/plugins/releases/download/v1.3.0/cni-plugins-linux-amd64-v1.3.0.tgz
mkdir -p /opt/cni/bin
tar -xvf cni-plugins-linux-amd64-v1.3.0.tgz -C /opt/cni/bin
containerd config default > /etc/containerd/config.toml
sed -i "s/SystemdCgroup = false/SystemdCgroup = true/g" /etc/containerd/config.toml
sed -i "s/cri//g" /etc/containerd/config.toml
systemctl restart containerd
popd