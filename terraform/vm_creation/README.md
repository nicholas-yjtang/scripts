# Purpose
This terraform script will create a VM using a csv which contains
1. username
2. hostname
3. path to ssh public key

Each VM will have this user created and the ssh public key will be added to the authorized_keys file.
The VM hostname will be set according to the hostname in the csv.
An additional administrator user will also be created with the ssh public key added to the authorized_keys file.
Both users will be added to the sudo group, so they can run commands with sudo without password

## Generate user csv
Generate the user csv using the following command
```bash
./generate_user_csv.sh [number of users] [username prefix] [hostname prefix] [ssh public key path] [output csv path]
```
It will generate the number of users you require, along with the hostname and ssh public key path. This is for testing only so you can also create the csv manually.

Generate the administrator ssh key with the following command
```bash
./generate_administrator_ssh_key.sh [administrator username] [administrator ssh public key path]
```
The generated ssh key name will be [administrator username]_key and [administrator username]_key.pub

This script is for testing only, so you can simply create the ssh key manually, and modify the main.tf file for the administrator username and the ssh public key path.

```terraform
variable "admin" { default = "administrator" }
variable "admin_ssh_key" { default = "ssh_keys/admin_key.pub" }

```
