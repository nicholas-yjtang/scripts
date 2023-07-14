#!/bin/bash
#generate a ssh key for root and ssh key for k8s admin
#usage: ./generate_root.sh <root_username> <output_folder>

root_username=administrator
if [ $# -ge 1 ]; then
    root_username=$1
fi

ssh_outputfolder=ssh_keys
if [ $# -ge 2 ]; then
    ssh_outputfolder=$2
fi
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd $CURRENT_DIR/..
mkdir -p $ssh_outputfolder
key_file="$ssh_outputfolder/${root_username}_key"
ssh-keygen -t rsa-sha2-512 -b 4096 -C "$root_username" -f "$key_file" -N ""
echo "SSH key generated for $root_username. Public key: ${key_file}.pub"
ssh-keygen -t rsa-sha2-512 -b 4096 -C "administrator@k8control" -f "$ssh_outputfolder/k8s_admin_key" -N ""
echo "SSH key generated for administrator@k8control. Public key: ${ssh_outputfolder}/k8s_admin_key.pub"
popd