#!/bin/bash
CURRENT_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DATA_DIR=$CURRENT_SCRIPT_DIR/../data
CONF_DIR=$CURRENT_SCRIPT_DIR/../conf
pushd $CURRENT_SCRIPT_DIR/..
if [ -z "$LDAP_ADMIN" ]; then
    echo "ADMIN_USER is not set, setting default of admin"
    LDAP_ADMIN=admin
fi

if [ -z "$DOMAIN" ]; then
    echo "DOMAIN is not set, deriving from hostname"
    DOMAIN=$(echo $HOSTNAME | cut -d. -f2-)
    if [ -z "$DOMAIN" ]; then
        echo "DOMAIN is not set, setting default of example.local"
        DOMAIN=example.local
    fi
fi

if [ -z "$BASE_DN" ]; then
    BASE_DN=$(echo $DOMAIN | sed -E 's/^([a-zA-Z0-9]+\.?)+/dc=&/g' | sed -E 's/\./,dc=/g') 
fi

if [ -z "$ORGANIZATION" ]; then
    echo "ORGANIZATION is not set, setting default to first part of DOMAIN"
    ORGANIZATION=$(echo $DOMAIN | cut -d. -f1)
fi

if [ -z "$LDAP_ADMIN_PASSWORD" ]; then
    if [ -f $DATA_DIR/ldap_admin_password.txt ]; then
        LDAP_ADMIN_PASSWORD=$(cat $DATA_DIR/ldap_admin_password.txt)
    else
        echo "LDAP_ADMIN_PASSWORD is not set"
        exit 1
    fi
fi

sed -i "s/\$BASE_DN/$BASE_DN/g" $CONF_DIR/organization.ldif
sed -i "s/\$ORGANIZATION/$ORGANIZATION/g" $CONF_DIR/organization.ldif

ldapadd -x -H ldap://$HOSTNAME -D "cn=$LDAP_ADMIN,$BASE_DN" -w $LDAP_ADMIN_PASSWORD -f $CONF_DIR/organization.ldif -ZZ -d 5
if [ $? -eq 0 ]; then
    echo "Create organization successful"
else
    echo "Create organization failed"
    exit 1
fi
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
    ldapdelete -x -H ldap://ldap.$DOMAIN -D "cn=$LDAP_ADMIN,$BASE_DN" -w $LDAP_ADMIN_PASSWORD "cn=$USER,$BASE_DN" -ZZ
    ldapadd -x -H ldap://ldap.$DOMAIN -D "cn=$LDAP_ADMIN,$BASE_DN" -w $LDAP_ADMIN_PASSWORD -f $DATA_DIR/user$i.ldif -ZZ
    if [ $? -eq 0 ]; then
        echo "Create user $USER successful"
    else
        echo "Create user $USER failed"
        exit 1
    fi
done
popd
if [ $? -eq 0 ]; then
    echo "Create users successful"
else
    echo "Create users failed"
    exit 1
fi