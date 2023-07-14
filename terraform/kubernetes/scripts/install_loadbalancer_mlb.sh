#!/bin/bash
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
USERNAME=$1
if [ -z "$USERNAME" ]; then
    echo "No username was sent to the script, exiting"
    exit 1
fi
pushd /home/$USERNAME
kubectl get configmap kube-proxy -n kube-system -o yaml | sed -e "s/strictARP: false/strictARP: true/" | kubectl apply -f - -n kube-system
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.10/config/manifests/metallb-native.yaml
if [ ! -f $CURRENT_DIR/metallb-addresspool.yaml ]; then
    echo "Address pool configuration file not found. Exiting."
    exit 1
fi
counter=0
while true;
do
    echo "Waiting for metallb to be ready"
    sleep 5
    kubectl get pods -n metallb-system | grep "Running" | grep "1/1"
    if [ $? -ne 0 ] ; then
        echo "Metallb not ready yet"
    else
        echo "Metallb is ready"
        break
    fi
    counter=$((counter+1))
    if [ $counter -gt 12 ]; then
        echo "Metallb not ready after 60 seconds. Exiting."
        exit 1
    fi
done
kubectl apply -f $CURRENT_DIR/metallb-addresspool.yaml
popd