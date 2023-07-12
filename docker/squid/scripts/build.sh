#!/bin/bash
wget http://www.squid-cache.org/Versions/v6/squid-6.1.tar.gz
if [ ! -f squid-6.1.tar.gz ]; then
    echo "Failed to download squid-6.1.tar.gz"
    exit 1
fi
tar -xvf squid-6.1.tar.gz
pushd squid-6.1
./configure --prefix=/opt/squid --enable-ssl-crtd --with-openssl -with-default-user=proxy --with-large-files
if [ $? -ne 0 ]; then
    echo "Failed to configure"
    exit 1
fi
make -j
if [ $? -ne 0 ]; then
    echo "Failed to make"
    exit 1
fi
make install
if [ $? -ne 0 ]; then
    echo "Failed to install"
    exit 1
fi