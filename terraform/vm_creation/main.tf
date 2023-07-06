
terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  ## Configuration options
  uri = "qemu:///system"
}


locals {
  csv_data=file("${path.module}/users.csv")
  instances=csvdecode(local.csv_data)
}

variable "hostname" { default = "server" }
variable "memoryMB" { default = 1024 * 4 }
variable "cpu" { default = 2 }
variable "disksizeMB" { default = 1024 * 1024 * 1024 * 25 }
variable "networkname" { default = "vm_network" }
variable "admin" { default = "administrator" } #admin user, caution: do not use admin as username
variable "admin_ssh_key" { default = "ssh_keys/admin_key.pub" }

resource "libvirt_volume" "ubuntu-qcow2" {
  for_each = { for inst in local.instances : inst.username => inst } #create a map with username as key
  name           = "ubuntu-${each.value.username}.qcow2"
  pool = "default"
  source = "file:///iso/ubuntu-22.04-server-cloudimg-amd64.img" #local instance so it is faster to create
  #source = "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"

}


resource "libvirt_network" "ubuntu_network" {
  name = var.networkname
  mode      = "nat"
  autostart = true
  dhcp {
    enabled = true
  }  
  addresses = ["10.0.2.0/24"]
}

data "template_file" "user_data" {
  for_each = { for inst in local.instances : inst.username => inst } #create a map with username as key
  template = file("${path.module}/cloud_init.yaml")
  vars = {
    hostname = each.value.hostname
    ssh_key = file(each.value.ssh_key)
    username = each.value.username
    admin = var.admin
    admin_key = file(var.admin_ssh_key)
  }  
}



resource "libvirt_cloudinit_disk" "commoninit" {
  for_each = { for inst in local.instances : inst.username => inst } #create a map with username as key
  name      = "commoninit-${each.value.username}.iso"
  user_data = data.template_file.user_data[each.value.username].rendered
}

# Define KVM domain to create
resource "libvirt_domain" "domain" {
  for_each   = { for inst in local.instances : inst.username => inst } #create a map with username as key
  name   = "${each.value.hostname}-${each.value.username}"
  memory     = var.memoryMB
  vcpu       = var.cpu
  qemu_agent = true
  autostart  = false

  cpu {
    mode = "host-model"
  }

  disk {
    volume_id = libvirt_volume.ubuntu-qcow2[each.value.username].id
  }

  network_interface {
    network_id = libvirt_network.ubuntu_network.id
    hostname = "${each.value.hostname}"
  }

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }

  cloudinit = libvirt_cloudinit_disk.commoninit[each.value.username].id

  depends_on = [
    libvirt_network.ubuntu_network
  ]


}

output "ips" {
  # show IP, run 'terraform refresh' if not populated
  value = [for inst in local.instances : libvirt_domain.domain[inst.username].network_interface.0.addresses]
}
