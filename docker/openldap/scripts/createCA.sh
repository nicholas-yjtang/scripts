#!/bin/bash
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd $CURRENT_DIR/..
if [ -z "$DOMAIN" ]; then
    echo "DOMAIN is not set, deriving the domain from hostname"
    DOMAIN=$(echo $HOSTNAME | cut -d. -f2-)
    if [ -z "$DOMAIN" ]; then
        echo "DOMAIN is not set, setting default of example.local"
        DOMAIN=example.local
    fi
fi
if [ -z "$CA_NAME" ]; then
    echo "CA_NAME is not set, setting default to first part of DOMAIN and underscore CA"
    CA_NAME=$(echo $DOMAIN | cut -d. -f1)_CA
fi
if [ -z "$ORGANIZATION" ]; then
    echo "ORGANIZATION is not set, setting default to first part of DOMAIN"
    ORGANIZATION=$(echo $DOMAIN | cut -d. -f1)
fi
if [ ! -d data ]; then
    mkdir -p data
fi
echo $RANDOM > data/passphrase.txt
PASS_PHRASE=$(cat data/passphrase.txt)
if [ -d /etc/ssl/$CA_NAME ]; then
    rm -rf /etc/ssl/$CA_NAME
fi
mkdir -p /etc/ssl/$CA_NAME/{certs,private,crl,newcerts,csr}
cp /etc/ssl/openssl.cnf /etc/ssl/$CA_NAME/openssl.cnf
sed -E -i "s/(dir\s*=\s*).*/\1\/etc\/ssl\/$CA_NAME/" /etc/ssl/$CA_NAME/openssl.cnf
echo 01 > /etc/ssl/$CA_NAME/serial
touch /etc/ssl/$CA_NAME/index.txt
echo "unique_subject = no" >> /etc/ssl/$CA_NAME/index.txt.attr
sed -E -i "s/#unique_subject.*/unique_subject = no/" /etc/ssl/$CA_NAME/openssl.cnf
openssl genrsa -passout pass:$PASS_PHRASE -out /etc/ssl/$CA_NAME/private/cakey.pem 4096 
openssl req -new -x509 -sha256 -config /etc/ssl/$CA_NAME/openssl.cnf -days 3650 -key /etc/ssl/$CA_NAME/private/cakey.pem -out /etc/ssl/$CA_NAME/cacert.pem -subj "/C=SG/ST=SG/O=$ORGANIZATION/CN=$DOMAIN" -passin pass:$PASS_PHRASE
popd
username=$1
if [ -z "$username" ]; then
    exit 0
fi
chown -R $username:$username /etc/ssl/$CA_NAME