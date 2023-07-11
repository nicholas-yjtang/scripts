#!/bin/bash
apt update && apt install -y squid-openssl
pushd /etc/squid/
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=SG/ST=SG/L=Singapore/O=IT/CN=proxy-server" -keyout bump.key  -out bump.crt
openssl x509 -in bump.crt -outform DER -out bump.der
openssl dhparam -outform PEM -out /etc/squid/bump_dhparam.pem 2048
chown proxy:proxy /etc/squid/bump*
chmod 400 /etc/squid/bump*
systemctl stop squid
mkdir -p /var/lib/squid
rm -rf /var/lib/squid/ssl_db
/usr/lib/squid/security_file_certgen -c -s /var/lib/squid/ssl_db -M 20MB
chown -R proxy:proxy /var/lib/squid/
popd
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd $CURRENT_DIR
cp squid.conf /etc/squid/squid.conf
popd
systemctl start squid