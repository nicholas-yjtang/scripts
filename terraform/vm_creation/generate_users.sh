#!/bin/bash
#generate a csv file with user names and hostnames
#usage: ./generate_users.sh <number of users> <username_prefix> <hostname_prefix> <ssh_outputfolder> <output file>

#check how many arguments were passed
if [ $# -lt 1 ]; then
    echo "Usage: ./generate_users.sh <number of users> <username_prefix> <hostname_prefix> <ssh_outputfolder> <output file>"
    exit 1
fi

#check if the first argument is a number
if ! [[ $1 =~ ^[0-9]+$ ]]; then
    echo "The first argument must be a number"
    exit 1
fi

username_prefix=user
if [ $# -ge 2 ]; then
    username_prefix=$2
fi

hostname_prefix=server
if [ $# -ge 3 ]; then
    hostname_prefix=$3
fi

ssh_outputfolder=ssh_keys
if [ $# -ge 4 ]; then
    ssh_outputfolder=$4
fi

output_file=users.csv
if [ $# -ge 5 ]; then
    output_file=$5
fi

if [ ! -d $ssh_outputfolder ]; then
    mkdir -p $ssh_outputfolder
fi

#if file exists, delete it
if [ -f $output_file ]; then
    rm $output_file
fi

#generate the csv file, with a hostname column and a username column
echo "username,hostname,ssh_key" >> $output_file

for i in $(seq 1 $1); do
    username="$username_prefix-$RANDOM"
    echo "Generating username $username"    
    hostname="$hostname_prefix-$RANDOM"
    echo "Generating hostname $hostname"
    echo "Generating SSH key for $username"
    # Generate the SSH key pair for the student
    key_file="$ssh_outputfolder/${username}_key"
    ssh-keygen -t rsa -b 4096 -C "$username@$hostname" -f "$key_file" -N ""
    echo "SSH key generated for $username. Public key: ${key_file}.pub"
    echo "$username,$hostname,$key_file.pub" >> $output_file

done