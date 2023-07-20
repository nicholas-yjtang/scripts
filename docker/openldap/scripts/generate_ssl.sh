#!/bin/bash
if [ -z "$CA_CN" ]; then
    echo "CA_CN is not set, setting default of example.local"
    CA_CN=example.local
fi
if [ -z "$CA_NAME" ]; then
    echo "CA_NAME is not set, setting default of example_CA"
    CA_NAME=example_CA
fi
CA_CONFIG_FILE=/etc/ssl/$CA_NAME/openssl.cnf
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DATA_DIR=$CURRENT_DIR/../data
CERTS_DIR=$CURRENT_DIR/../certs

if [ -d $CERTS_DIR ]; then
    rm -rf $CERTS_DIR
fi
mkdir $CERTS_DIR
pushd $CERTS_DIR
openssl req -new -newkey rsa:2048 -nodes -keyout tls.key -out newreq.pem -subj "/C=SG/ST=SG/CN=ldap.$CA_CN/O=Example"
openssl ca -config $CA_CONFIG_FILE -in newreq.pem -out tls.crt -extensions v3_req -batch -passin pass:$(cat $DATA_DIR/passphrase.txt)
cp /etc/ssl/$CA_NAME/cacert.pem ca.crt
openssl dhparam -outform PEM -out dhparam.pem 2048

openssl req -new -newkey rsa:2048 -nodes -keyout client_tls.key -out client_newreq.pem -subj "/C=SG/ST=SG/CN=client.$CA_CN/O=Example"
openssl ca -config $CA_CONFIG_FILE -in client_newreq.pem -out client_tls.crt -extensions v3_req -batch -passin pass:$(cat $DATA_DIR/passphrase.txt)
popd
