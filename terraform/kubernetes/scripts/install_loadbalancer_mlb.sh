#!/bin/bash
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
USERNAME=$1
if [ -z "$USERNAME" ]; then
    echo "No username was sent to the script, exiting"
    exit 1
fi
pushd /home/$USERNAME
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.10/config/manifests/metallb-native.yaml
if [ ! -f $CURRENT_DIR/metallb-addresspool.yaml ]; then
    echo "Address pool configuration file not found. Exiting."
    exit 1
fi
kubectl apply -f $CURRENT_DIR/metallb-addresspool.yaml
popd