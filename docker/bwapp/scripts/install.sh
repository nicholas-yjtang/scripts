#!/bin/bash
pushd /var/www/html
unzip bWAPPv2.2.zip
pushd bWAPP
chmod 777 passwords/
chmod 777 images/
chmod 777 documents/
mkdir logs
chmod 777 logs/
sed -i 's/$db_server = "localhost";/$db_server = "127.0.0.1";/g' /var/www/html/bWAPP/admin/settings.php
sed -i 's/$db_username = "root";/$db_username = "bwapp";/g' /var/www/html/bWAPP/admin/settings.php
sed -i 's/$db_password = "";/$db_password = "bug";/g' /var/www/html/bWAPP/admin/settings.php
if [ $? -eq 0 ]; then
    echo "bWAPP installed successfully"
else
    echo "bWAPP installation failed"
    exit 1
fi
popd
popd
mysqld -u root &
sleep 1
mysql -u root < install.sql
if [ $? -eq 0 ]; then
    echo "sql installed successfully"
else
    echo "sql installation failed"
    exit 1
fi
apachectl start
response=$(curl http://localhost/bWAPP/install.php?install=yes)
if [ -z "$response" ]; then
    echo "bWAPP installation failed"
    exit 1
fi
if [ $? -eq 0 ]; then
    echo "bWAPP installed successfully"
else
    echo "bWAPP installation failed"
    exit 1
fi
apachectl stop