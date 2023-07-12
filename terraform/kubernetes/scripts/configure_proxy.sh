#!/bin/bash
proxy_server=$1
if [ -z "$proxy_server" ]
then
      echo "No proxy server supplied"
      exit 1
fi
echo 'Acquire::http::Proxy "http://'$proxy_server'";' >> /etc/apt/apt.conf.d/proxy.conf
echo 'Acquire::https::Proxy "http://'$proxy_server'";' >> /etc/apt/apt.conf.d/proxy.conf
echo 'Acquire::https::Verify-Peer "false";' >> /etc/apt/apt.conf.d/proxy.conf
echo 'Acquire::https::Verify-Host "false";' >> /etc/apt/apt.conf.d/proxy.conf
