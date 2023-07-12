#!/bin/bash
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd $CURRENT_DIR
count=0
while [ ! -f "done.txt" ]; do
  echo "Waiting for runcmd to finish"
  sleep 5
  count = $((count+1))
  if [ $count -gt 30 ]; then
    echo "Timeout waiting for runcmd to finish"
    exit 1
  fi
done