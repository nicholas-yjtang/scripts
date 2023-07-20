#!/bin/bash
CURRENT_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
if [ ! -d /opt/openldap ]; then
    mkdir -p /opt/openldap
fi
BUILD_DIR=$CURRENT_SCRIPT_DIR/../build
if [ ! -d $BUILD_DIR ]; then
    mkdir $BUILD_DIR
fi
pushd $BUILD_DIR
if [ ! -f openldap-2.5.15.tgz ]; then
    wget https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-2.5.15.tgz --no-check-certificate
fi
if [ ! -d openldap-2.5.15 ]; then
    tar -xvf openldap-2.5.15.tgz
fi
if [ ! -f /opt/openldap/libexec/slapd ]; then
    pushd openldap-2.5.15
    ./configure --prefix=/opt/openldap --enable-crypt
    if [ $? -ne 0 ]; then
        echo "Configure failed"
        exit 1
    fi
    make depend
    if [ $? -ne 0 ]; then
        echo "Make depend failed"
        exit 1
    fi
    make -j
    if [ $? -ne 0 ]; then
        echo "Make failed"
        exit 1
    fi
    make install
    if [ $? -ne 0 ]; then
        echo "Make install failed"
        exit 1
    fi
    popd
fi
popd