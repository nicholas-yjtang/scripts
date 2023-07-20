#!/bin/bash
CURRENT_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd $CURRENT_SCRIPT_DIR/..
./scripts/kill.sh
./scripts/compile.sh
if [ $? -eq 0 ]; then
    echo "Compile successful"
else
    echo "Compile failed"
    exit 1
fi
./scripts/createCA.sh
if [ $? -eq 0 ]; then
    echo "Create CA successful"
else
    echo "Create CA failed"
    exit 1
fi
./scripts/generate_ssl.sh
if [ $? -eq 0 ]; then
    echo "Generate SSL successful"
else
    echo "Generate SSL failed"
    exit 1
fi
./scripts/init.sh
if [ $? -eq 0 ]; then
    echo "Init successful"
else
    echo "Init failed"
    exit 1
fi
./scripts/run.sh
if [ $? -eq 0 ]; then
    echo "Run successful"
else
    echo "Run failed"
    exit 1
fi
./scripts/createUsers.sh
if [ $? -eq 0 ]; then
    echo "Create users successful"
else
    echo "Create users failed"
    exit 1
fi
./scripts/kill.sh
popd