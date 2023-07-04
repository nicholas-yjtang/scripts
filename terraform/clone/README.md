# Introduction

The purpose of this script is to clone the particular VM into multiple instances for kvm only.

The script will change the hostname to "ubuntu" and add a running number based on the number of serverCount you wish to set.

Ensure the VM has installed the following packages:

- cloud-init
- qemu-guest-agent

Run terraform init, plan and apply to create the VMs.