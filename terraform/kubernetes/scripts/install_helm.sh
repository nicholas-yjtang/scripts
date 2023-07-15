#!/bin/bash
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd $CURRENT_DIR/..
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
popd
USERNAME=$1
if [ -z "$USERNAME" ]; then
    echo "No username was sent to the script, exiting"
    exit 1
fi

pushd /home/$USERNAME
helm repo add bitnami https://charts.bitnami.com/bitnami
if [ ! -f .bashrc ]; then
    echo "No .bashrc found"
    exit 1
fi

if grep --quiet "source <(helm completion bash)" .bashrc; then
    echo "Helm completion already in .bashrc"
else
    echo "source <(helm completion bash)" >> .bashrc
fi

if [ ! -d .config ]; then
    echo "No .config directory found"
    exit 1
fi
sudo chown -R $USERNAME:$USERNAME .config
popd