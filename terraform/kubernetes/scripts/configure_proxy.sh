#!/bin/bash
proxy_server=$1
if [ -z "$proxy_server" ]
then
      echo "No proxy server supplied"
      exit 1
fi
private_network_addresses="10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"

echo 'Acquire::http::Proxy "http://'$proxy_server'";' >> /etc/apt/apt.conf.d/proxy.conf
echo 'Acquire::https::Proxy "http://'$proxy_server'";' >> /etc/apt/apt.conf.d/proxy.conf
echo 'Acquire::https::Verify-Peer "false";' >> /etc/apt/apt.conf.d/proxy.conf
echo 'Acquire::https::Verify-Host "false";' >> /etc/apt/apt.conf.d/proxy.conf

#for wget, curl, etc.
echo 'export http_proxy="http://'$proxy_server'"' >> ~/.bashrc
echo 'export https_proxy="http://'$proxy_server'"' >> ~/.bashrc
echo 'export no_proxy="localhost,127.0.0.0/8,::1,'$private_network_addresses'"' >> ~/.bashrc

username=$2
if [ -z "$username" ]
then
      echo "No username supplied"
      exit 1
fi

#set in environment
#echo 'export http_proxy="http://'$proxy_server'"' >> /home/$username/.bashrc
#echo 'export https_proxy="http://'$proxy_server'"' >> /home/$username/.bashrc
#echo 'export no_proxy="localhost,127.0.0.0/8,::1,'$private_network_addresses'"' >> /home/$username/.bashrc

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cat <<EOF > $CURRENT_DIR/wgetrc
check-certificate = off
proxy = on
http-proxy = $proxy_server
https-proxy = $proxy_server
no-proxy = localhost,127.0.0.0/8,::1,$private_network_addresses
EOF

cat $CURRENT_DIR/wgetrc >> /etc/wgetrc
cat $CURRENT_DIR/wgetrc >> ~/.wgetrc
cat $CURRENT_DIR/wgetrc >> /home/$username/.wgetrc
chown $username:$username /home/$username/.wgetrc

cat <<EOF > $CURRENT_DIR/curlrc
insecure
proxy = $proxy_server
EOF
cat $CURRENT_DIR/curlrc >> /etc/curlrc
cat $CURRENT_DIR/curlrc >> ~/.curlrc
cat $CURRENT_DIR/curlrc >> /home/$username/.curlrc
chown $username:$username /home/$username/.curlrc