#!/bin/bash
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/master/stable.txt)
CLI_ARCH=amd64
CILIUM_VERSION=$2
if [ -z "$CILIUM_VERSION" ]; then
    echo "No Cilium version was sent to the script, using default 1.13.4"
    CILIUM_VERSION=1.13.4
fi

POD_CIDR=$3
if [ -z "$POD_CIDR" ]; then
    echo "No POD_CIDR was sent to the script, using default 192.168.0.0/16"
    POD_CIDR=192.168.0.0/16
fi

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd $CURRENT_DIR
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
popd
USERNAME=$1
if [ -z "$USERNAME" ]; then
    echo "No username was sent to the script, exiting"
    exit 1
fi
pushd /home/$USERNAME
helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium --version $CILIUM_VERSION \
    --namespace kube-system \
    --set ipam.operator.clusterPoolIPv4PodCIDR=$POD_CIDR
cilium status --wait
if [ -f .bashrc ]; then
    if grep --quiet "source <(cilium completion bash)" .bashrc; then
        echo "Cilium completion already in .bashrc"
    else
        echo "source <(cilium completion bash)" >> .bashrc
    fi
fi
#cilium connectivity test
popd