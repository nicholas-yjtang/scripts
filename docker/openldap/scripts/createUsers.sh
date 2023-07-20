#!/bin/bash
CURRENT_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DATA_DIR=$CURRENT_SCRIPT_DIR/../data
CONF_DIR=$CURRENT_SCRIPT_DIR/../conf
pushd $CURRENT_SCRIPT_DIR/..
if [ -z "$LDAP_ADMIN" ]; then
    echo "ADMIN_USER is not set, setting default of admin"
    LDAP_ADMIN=admin
fi

if [ -z "$BASE_DN" ]; then
    echo "BASE_DN is not set, setting default of dc=example,dc=local"
    BASE_DN=dc=example,dc=local
fi

if [ -z "$CA_CN" ]; then
    echo "CA_CN is not set, setting default of example.local"
    CA_CN=example.local
fi

if [ -z "$LDAP_ADMIN_PASSWORD" ]; then
    if [ -f $DATA_DIR/ldap_admin_password.txt ]; then
        LDAP_ADMIN_PASSWORD=$(cat $DATA_DIR/ldap_admin_password.txt)
    else
        echo "LDAP_ADMIN_PASSWORD is not set"
        exit 1
    fi
fi
ldapadd -x -H ldap://ldap.$CA_CN -D "cn=$LDAP_ADMIN,$BASE_DN" -w $LDAP_ADMIN_PASSWORD -f $CONF_DIR/organization.ldif -ZZ

if [ -z "$NUMBER_OF_USERS" ]; then
    echo "NUMBER_OF_USERS is not set, setting default of 100"
    NUMBER_OF_USERS=100
fi

if [ -f $DATA_DIR/users.csv ]; then
    rm -f $DATA_DIR/users.csv
fi

echo "uid,password" >> $DATA_DIR/users.csv

for i in $(seq 1 $NUMBER_OF_USERS); do
    USER=$(printf "user%03d" $i)
    echo "Creating user $USER"
    cp $CONF_DIR/user_template.ldif $DATA_DIR/user$i.ldif
    sed -i "s/\$UID$/$USER/g" $DATA_DIR/user$i.ldif
    sed -i "s/\$UID_DN$/cn=$USER,$BASE_DN/g" $DATA_DIR/user$i.ldif
    sed -i "s/\$UID_NUMBER$/$((10000+$i))/g" $DATA_DIR/user$i.ldif
    sed -i "s/\$GID_NUMBER$/$((10000+$i))/g" $DATA_DIR/user$i.ldif
    password=$(openssl rand -base64 32)
    echo "$USER,$password" >> $DATA_DIR/users.csv
    password_hash=$(/opt/openldap/sbin/slappasswd -s $password)
    password_hash=${password_hash//\//\\\/} # escape / in password
    password_hash=${password_hash//\+/\\\+} # escape + in password
    echo "password_hash: $password_hash"
    sed -i "s/\$PASSWORD_HASH/$password_hash/g" $DATA_DIR/user$i.ldif
    ldapdelete -x -H ldap://ldap.$CA_CN -D "cn=$LDAP_ADMIN,$BASE_DN" -w $LDAP_ADMIN_PASSWORD "cn=$USER,$BASE_DN" -ZZ
    ldapadd -x -H ldap://ldap.$CA_CN -D "cn=$LDAP_ADMIN,$BASE_DN" -w $LDAP_ADMIN_PASSWORD -f $DATA_DIR/user$i.ldif -ZZ
done

popd