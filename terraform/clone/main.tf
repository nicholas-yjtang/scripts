
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


variable "hostname" { default = "ubuntu" }
variable "memoryMB" { default = 1024 * 4 }
variable "cpu" { default = 2 }
variable "disksizeMB" { default = 1024 * 1024 * 1024 * 25 }
variable "serverCount" { default = 2 }
variable "networkname" { default = "ubuntu_network" }

resource "libvirt_volume" "ubuntu-qcow2" {
  count          = var.serverCount
  name           = "ubuntu-${count.index}.qcow2"
  pool = "default"
  source = "file:///kvm/pools/homelab/ubuntu20.04.qcow2"

}

resource "libvirt_network" "ubuntu_network" {
  name = var.networkname
  mode      = "nat"
  autostart = true
  dhcp {
    enabled = true
  }  
  addresses = ["10.0.1.0/24"]
}

data "template_file" "user_data" {
  count = var.serverCount
  template = file("${path.module}/cloud_init.yaml")
  vars = {
    hostname = "${var.hostname}-${count.index}"
  }  
}

resource "libvirt_cloudinit_disk" "commoninit" {
  count = var.serverCount
  name      = "commoninit-${count.index}.iso"
  user_data = data.template_file.user_data[count.index].rendered
}

# Define KVM domain to create
resource "libvirt_domain" "domain" {
  count    = var.serverCount
  name   = "${var.hostname}-${count.index}"
  memory     = var.memoryMB
  vcpu       = var.cpu
  qemu_agent = true
  autostart  = true

  cpu {
    mode = "host-model"
  }

  disk {
    volume_id = element(libvirt_volume.ubuntu-qcow2.*.id, count.index)
  }

  network_interface {
    network_id = libvirt_network.ubuntu_network.id
    hostname = "${var.hostname}-${count.index}"
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

  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id

  depends_on = [
    libvirt_network.ubuntu_network
  ]


}

output "ips" {
  # show IP, run 'terraform refresh' if not populated
  value = libvirt_domain.domain.*.network_interface.0.addresses
}
