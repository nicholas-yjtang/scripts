#!/bin/bash
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd $CURRENT_DIR
while [ ! -f "done.txt" ]; do
  echo "Waiting for runcmd to finish"
  sleep 5
done