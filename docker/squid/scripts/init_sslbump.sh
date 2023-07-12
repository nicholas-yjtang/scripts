#!/bin/bash
SQUID_ETC_DIR=/opt/squid/etc
pushd $SQUID_ETC_DIR
BUMP_KEY=bump.key
BUMP_CRT=bump.crt
BUMP_DER=bump.der
BUMP_DHPARAM=bump_dhparam.pem
if [ -f $BUMP_KEY ]; then
    rm -f $BUMP_KEY
fi
if [ -f $BUMP_CRT ]; then
    rm -f $BUMP_CRT
fi
if [ -f $BUMP_DER ]; then
    rm -f $BUMP_DER
fi
if [ -f $BUMP_DHPARAM ]; then
    rm -f $BUMP_DHPARAM
fi
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -subj "/C=SG/ST=SG/L=Singapore/O=IT/CN=proxy-server" -keyout $BUMP_KEY  -out $BUMP_CRT
openssl x509 -in $BUMP_CRT -outform DER -out $BUMP_DER
openssl dhparam -outform PEM -out $BUMP_DHPARAM 2048
chmod 400 $SQUID_ETC_DIR/bump*
popd
SQUID_SSL_DB=/opt/squid/ssl_db
if [ -d $SQUID_SSL_DB ]; then
    rm -rf $SQUID_SSL_DB
fi
/opt/squid/libexec/security_file_certgen -c -s $SQUID_SSL_DB -M 20MB
if [ $? -ne 0 ]; then
    echo "Failed to generate ssl_db"
    exit 1
fi