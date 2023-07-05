#!/bin/bash
#generate a ssh key for root
#usage: ./generate_root.sh <number of users> <output file>

root_username=admin
if [ $# -ge 1 ]; then
    root_username=$1
fi

ssh_outputfolder=ssh_keys
if [ $# -ge 2 ]; then
    username_prefix=$2
fi

key_file="$ssh_outputfolder/${root_username}_key"
ssh-keygen -t rsa -b 4096 -C "$root_username" -f "$key_file" -N ""
echo "SSH key generated for $root_username. Public key: ${key_file}.pub"