#!/bin/bash
address=$1
if [ -z "$address" ]
then
    echo "Warning, no proxy address to bind to, may behave incorrectly"
    exit 1
fi
hostname=$2
apt update && apt install -y apt-cacher-ng
sed -i -E 's/Port\:3142/Port\:8000/g' /etc/apt-cacher-ng/acng.conf
sed -i -E 's/(BindAddress\:\ .*)/\1\ ${address} ${hostname}/' /etc/apt-cacher-ng/acng.conf
systemctl restart apt-cacher-ng