#!/bin/bash
CURRENT_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd $CURRENT_SCRIPT_DIR/..
docker ps | grep openldap | awk '{print $1}' | xargs -I {} docker cp {}:/opt/openldap/certs certs
docker ps | grep openldap | awk '{print $1}' | xargs -I {} docker cp {}:/opt/openldap/data data
popd