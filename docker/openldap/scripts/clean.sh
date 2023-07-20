#!/bin/bash
CURRENT_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd $CURRENT_SCRIPT_DIR/..
rm -rf data
rm -rf certs
rm -rf build