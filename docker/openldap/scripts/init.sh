#!/bin/bash
CURRENT_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
OPENLDAP_DIR=/opt/openldap
if [ ! -d $OPENLDAP_DIR ]; then
    echo "OpenLDAP is not installed"
    exit 1
fi
pushd $CURRENT_SCRIPT_DIR/..
DATA_DIR=$(pwd)/data
CERT_DIR=$(pwd)/certs
OPENLDAP_ETC_DIR=$OPENLDAP_DIR/etc/openldap
if [ -z $LDAP_ADMIN ]; then
    echo "LDAP_ADMIN is not set, setting default of admin"
    LDAP_ADMIN=admin
fi

if [ -z $DOMAIN ]; then
    echo "DOMAIN is not set, deriving from hostname"
    DOMAIN=$(echo $HOSTNAME | cut -d. -f2-)
    if [ -z $DOMAIN ]; then
        echo "DOMAIN is not set, setting default of example.local"
        DOMAIN=example.local
    fi
fi

if [ -z $BASE_DN ]; then
    echo "BASE_DN is not set, setting from DOMAIN"
    BASE_DN=$(echo $DOMAIN | sed -E 's/^([a-zA-Z0-9]+\.?)+/dc=&/g' | sed -E 's/\./,dc=/g')
fi

cp $OPENLDAP_ETC_DIR/slapd.ldif.default $OPENLDAP_ETC_DIR/slapd.ldif
sed -E -i "s/olcSuffix:(.*)/olcSuffix: $BASE_DN/g" $OPENLDAP_ETC_DIR/slapd.ldif
sed -E -i "s/olcRootDN: cn=Manager(.*)/olcRootDN: cn=$LDAP_ADMIN,$BASE_DN/g" $OPENLDAP_ETC_DIR/slapd.ldif
if [ -z "$LDAP_ADMIN_PASSWORD" ]; then
    echo "LDAP_ADMIN_PASSWORD is not set"
    echo "Generating one with openssl"
    LDAP_ADMIN_PASSWORD=$(openssl rand -base64 32)
    echo "LDAP_ADMIN_PASSWORD: $LDAP_ADMIN_PASSWORD"
    if [ ! -d $DATA_DIR ]; then
        mkdir -p $DATA_DIR
    fi
    rm -f $DATA_DIR/ldap_admin_password.txt
    echo $LDAP_ADMIN_PASSWORD >> $DATA_DIR/ldap_admin_password.txt
    
fi
LDAP_ADMIN_PASSWORD_HASH=$($OPENLDAP_DIR/sbin/slappasswd -s $LDAP_ADMIN_PASSWORD)
LDAP_ADMIN_PASSWORD=${LDAP_ADMIN_PASSWORD//\//\\\/} # escape / in password
echo "LDAP_ADMIN_PASSWORD_HASH: $LDAP_ADMIN_PASSWORD_HASH"
LDAP_ADMIN_PASSWORD_HASH=${LDAP_ADMIN_PASSWORD_HASH//\//\\\/} # escape / in password
LDAP_ADMIN_PASSWORD_HASH=${LDAP_ADMIN_PASSWORD_HASH//\+/\\\+} # escape + in password
echo "LDAP_ADMIN_PASSWORD_HASH: $LDAP_ADMIN_PASSWORD_HASH"
sed -E -i "s/olcRootPW:(.*)/olcRootPW: $LDAP_ADMIN_PASSWORD/g" $OPENLDAP_ETC_DIR/slapd.ldif

sed -E -i "/#olcSecurity(.*)/a olcTLSCACertificateFile: $CERT_DIR/ca.crt" $OPENLDAP_ETC_DIR/slapd.ldif
sed -E -i "/#olcSecurity(.*)/a olcTLSCertificateFile: $CERT_DIR/tls.crt" $OPENLDAP_ETC_DIR/slapd.ldif
sed -E -i "/#olcSecurity(.*)/a olcTLSCertificateKeyFile: $CERT_DIR/tls.key" $OPENLDAP_ETC_DIR/slapd.ldif
sed -E -i "/#olcSecurity(.*)/a olcTLSVerifyClient: never" $OPENLDAP_ETC_DIR/slapd.ldif
sed -E -i "/#olcSecurity(.*)/a olcSecurity: tls=1" $OPENLDAP_ETC_DIR/slapd.ldif
sed -E -i "/#olcSecurity(.*)/a olcTLSCipherSuite: TLSv1:TLSv1.2:TLSv1.3" $OPENLDAP_ETC_DIR/slapd.ldif
sed -E -i "/#olcSecurity(.*)/a olcTLSCRLCheck: none"  $OPENLDAP_ETC_DIR/slapd.ldif

SLAPD_CONF_DIR=$OPENLDAP_ETC_DIR/slapd.d
if [ -d $SLAPD_CONF_DIR ]; then
    rm -rf $SLAPD_CONF_DIR
fi
if [ ! -d $SLAPD_CONF_DIR ]; then
    mkdir $SLAPD_CONF_DIR
fi
OPENLDAP_DATA_DIR=$OPENLDAP_DIR/var/openldap-data
if [ -d $OPENLDAP_DATA_DIR ]; then
    rm -rf  $OPENLDAP_DATA_DIR
fi
if [ ! -d $OPENLDAP_DATA_DIR ]; then
    mkdir -p $OPENLDAP_DATA_DIR
    chmod 700 $OPENLDAP_DATA_DIR
fi
$OPENLDAP_DIR/sbin/slapadd -n 0 -F $SLAPD_CONF_DIR -l $OPENLDAP_ETC_DIR/slapd.ldif
popd