#!/bin/bash
#Installing the CRI-O Container Runtime
apt update && apt install -y curl gnupg
DISTRIB_ID=$(awk ' /ID/ {split($1,a,"="); print a[2]}' /etc/lsb-release)
DISTRIB_RELEASE=$(awk ' /RELEASE/ {split($1,a,"="); print a[2]}' /etc/lsb-release)
OS='x'$DISTRIB_ID'_'$DISTRIB_RELEASE
VERSION=$1
if [ -z "$VERSION" ]; then
    VERSION=1.27
fi
echo "deb [signed-by=/usr/share/keyrings/libcontainers-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb [signed-by=/usr/share/keyrings/libcontainers-crio-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list
mkdir -p /usr/share/keyrings
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | gpg --dearmor -o /usr/share/keyrings/libcontainers-archive-keyring.gpg
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/Release.key | gpg --dearmor -o /usr/share/keyrings/libcontainers-crio-archive-keyring.gpg
apt update && apt install -y cri-o cri-o-runc