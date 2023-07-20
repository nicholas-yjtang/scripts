#!/bin/bash
if [ -z "$DOMAIN" ]; then
    echo "DOMAIN is not set, deriving from hostname"
    DOMAIN=$(echo $HOSTNAME | cut -d. -f2-)
    if [ -z "$DOMAIN" ]; then
        echo "DOMAIN is not set, setting default of example.local"
        DOMAIN=example.local
    fi
fi

if [ -z "$ORGANIZATION" ]; then
    echo "ORGANIZATION is not set, setting default to first part of DOMAIN"
    ORGANIZATION=$(echo $DOMAIN | cut -d. -f1)
fi

if [ -z "$CA_NAME" ]; then
    echo "CA_NAME is not set, setting default to first part of DOMAIN and underscore CA"
    CA_NAME=$(echo $DOMAIN | cut -d. -f1)_CA
fi

if [ -z "$CLIENT_NAME" ]; then
    echo "CLIENT_NAME is not set, setting default to client"
    CLIENT_NAME=client
fi

CA_CONFIG_FILE=/etc/ssl/$CA_NAME/openssl.cnf
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd $CURRENT_DIR/..
DATA_DIR=$(pwd)/data
CERTS_DIR=$(pwd)/certs
popd
if [ -d $CERTS_DIR ]; then
    rm -rf $CERTS_DIR
fi
mkdir $CERTS_DIR
pushd $CERTS_DIR
openssl req -new -newkey rsa:2048 -nodes -keyout tls.key -out newreq.pem -subj "/C=SG/ST=SG/CN=$HOSTNAME/O=$ORGANIZATION"
openssl ca -config $CA_CONFIG_FILE -in newreq.pem -out tls.crt -extensions v3_req -batch -passin pass:$(cat $DATA_DIR/passphrase.txt)
cp /etc/ssl/$CA_NAME/cacert.pem ca.crt
openssl dhparam -outform PEM -out dhparam.pem 2048

openssl req -new -newkey rsa:2048 -nodes -keyout client_tls.key -out client_newreq.pem -subj "/C=SG/ST=SG/CN=$CLIENT_NAME.$DOMAIN/O=$ORGANIZATION"
openssl ca -config $CA_CONFIG_FILE -in client_newreq.pem -out client_tls.crt -extensions v3_req -batch -passin pass:$(cat $DATA_DIR/passphrase.txt)

echo "TLS_KEY $CERTS_DIR/client_tls.key" >> /etc/ldap/ldap.conf
echo "TLS_CERT $CERTS_DIR/client_tls.crt" >> /etc/ldap/ldap.conf
echo "TLS_CACERT $CERTS_DIR/ca.crt" >> /etc/ldap/ldap.conf

popd
