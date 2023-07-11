#!/bin/bash
proxyip=$1
if [ -z "$proxyip" ]
then
      echo "No proxy IP supplied"
      exit 1
fi
echo 'Acquire::http::Proxy "http://'$proxyip':8000";' >> /etc/apt/apt.conf.d/proxy.conf
echo 'Acquire::https::Verify-Peer "false";' >> /etc/apt/apt.conf.d/proxy.conf
echo 'Acquire::https::Verify-Host "false";' >> /etc/apt/apt.conf.d/proxy.conf
