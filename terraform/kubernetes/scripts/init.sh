#!/bin/bash
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
modprobe br_netfilter
modprobe overlay
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system
lsmod | grep br_netfilter
lsmod | grep overlay
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

#for cilium, disable the management of foreign routes
sed -E -i "s/#ManageForeignRoutes=(.*)/ManageForeignRoutes=no/g" /etc/systemd/networkd.conf
sed -E -i "s/#ManageForeignRoutingPolicyRules=(.*)/ManageForeignRoutingPolicyRules=no/g" /etc/systemd/networkd.conf
systemctl daemon-reload
systemctl restart systemd-networkd