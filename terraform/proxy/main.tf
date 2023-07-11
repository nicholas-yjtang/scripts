
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


resource "libvirt_pool" "proxy" {
  name = "proxy"
  type = "dir"
  path = "/mnt/data/kvm/pools/proxy"
}

resource "libvirt_volume" "base_volume" {
  name = "base_volume.qcow2"
  pool = libvirt_pool.proxy.name
  source = "file:///iso/ubuntu-22.04-server-cloudimg-amd64.img" #faster to refer to local file
  #source = "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"

}

variable "hostname" { default = "proxy-server" }
variable "memoryMB" { default = 1024 * 4 }
variable "cpu" { default = 2 }
variable "disksizeMB" { default = 1024 * 1024 * 1024 * 100 }
variable "networkname" { default = "proxy_network" } #use proxy
variable "domain" { default = "proxy.local" } 
variable "admin" { default = "administrator" } #admin user, caution: do not use admin as username
variable "admin_ssh_key" { default = "ssh_keys/admin_key.pub" }
variable "address" { default = ["10.0.6.11"] } 


resource "libvirt_volume" "ubuntu-qcow2" {
  name           = "ubuntu-${var.hostname}.qcow2"
  pool = "default"
  base_volume_id = libvirt_volume.base_volume.id 
  size =  var.disksizeMB
}


resource "libvirt_network" "ubuntu_network" {
  name = var.networkname
  mode      = "nat"
  autostart = true
  domain = var.domain
  dhcp {
    enabled = true
  }  
  addresses = ["10.0.6.0/24"]
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.yaml")
  vars = {
    hostname = var.hostname
    admin = var.admin
    admin_key = file(var.admin_ssh_key)
    address = var.address[0]
    install_apt_cacher_ng_script = base64encode(file("${path.module}/scripts/install_apt_cacher_ng.sh"))
    install_squid_deb_proxy_script = base64encode(file("${path.module}/scripts/install_squid_deb_proxy.sh"))
    admin_passwd = file ("${path.module}/root_password.txt")
    install_ssl_squid_proxy_script = base64encode(file("${path.module}/scripts/install_ssl_squid_proxy.sh"))
    squid_conf = base64encode(file("${path.module}/config/squid.conf"))
  }  
}



resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "commoninit.iso"
  user_data = data.template_file.user_data.rendered
}

# Define KVM domain to create
resource "libvirt_domain" "domain" {
  name   = "${var.hostname}"
  memory     = var.memoryMB
  vcpu       = var.cpu
  qemu_agent = true
  autostart  = false

  cpu {
    mode = "host-model"
  }

  disk {
    volume_id = libvirt_volume.ubuntu-qcow2.id
  }

  network_interface {
    network_id = libvirt_network.ubuntu_network.id
    hostname = var.hostname
    addresses = var.address
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

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  depends_on = [
    libvirt_network.ubuntu_network
  ]


}

output "ips" {
  # show IP, run 'terraform refresh' if not populated
  value = libvirt_domain.domain.network_interface.0.addresses
}
