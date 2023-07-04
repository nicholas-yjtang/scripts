# Introduction

The purpose of this script is to clone the particular VM into multiple instances for kvm only. The source of the VM is found under libvirt_volume
```terraform
resource "libvirt_volume" "ubuntu-qcow2" {
    ...
    source = "file:///kvm/pools/homelab/ubuntu20.04.qcow2"
}
```

The script will change the hostname to "ubuntu" and add a running number based on the number of serverCount you wish to set.

Ensure the VM has installed the following packages:

- cloud-init
- qemu-guest-agent

Run terraform init, plan and apply to create the VMs.