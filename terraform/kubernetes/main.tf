
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


variable "hostname" { default = "kubernetes" }
variable "memoryMB" { default = 1024 * 12 }
variable "cpu" { default = 4 }
variable "disksizeMB" { default = 1024 * 1024 * 1024 * 50 }
variable "management_network" { default = "kubernetes_management" }
variable "management_gateway" {default="10.0.5.1"}
variable "management_dns" {default="10.0.5.1"}
variable "management_address" { default="10.0.5.0/24"}
variable "ssh_key" { default = "ssh_keys/administrator_key.pub" }
variable "username" { default = "administrator" }
variable "crio-version" { default = "1.27" } #some versions don't have the key for apt, so change as accordingly
variable "kube-version" { default = "1.27.0-00" } 
variable "k8s_admin_ssh_private_key" { default = "ssh_keys/k8s_admin_key" }
variable "k8s_admin_ssh_public_key" { default = "ssh_keys/k8s_admin_key.pub" }
variable "k8s_cluster_endpoint" { default = "k8s-cluster-endpoint" }
variable "provider_network" { default = "provider_network" }
variable "provider_gateway" {default="10.1.0.1"}
variable "provider_dns" {default="10.1.0.1"}
variable "provider_address" { default="10.1.0.0/16"}
variable "proxy_server" { default = "10.1.0.1:3128" }
variable "pod_cidr" { default = "192.168.0.0/16" }
variable "cilium_version" { default = "1.13.4" }
#nfs server related terraform
variable "nfs_server_hostname" { default = "nfs-server" }
variable "nfs_server_ip" { default = "10.0.5.12" } 
variable "nfs_server_path" { default = "/mnt/data/nfs" }
variable "nfs_disksizeMB" { default = 1024 * 1024 * 1024 * 40 }
variable "nfs_data_disksizeMB" { default = 1024 * 1024 * 1024 * 100 }
variable "nfs_cpu" { default = 2 }
variable "nfs_memoryMB" { default = 1024 * 8 }
#loadbalancer pool
variable "loadbalancer_pool" { default = "10.1.1.1-10.1.255.254" }

resource "libvirt_pool" "cluster" {
  name = "cluster"
  type = "dir"
  path = "/mnt/data/kvm/pools/cluster"
}

resource "libvirt_volume" "base_volume" {
  name = "base_volume.qcow2"
  pool = libvirt_pool.cluster.name
  source = "file:///iso/ubuntu-22.04-server-cloudimg-amd64.img" #faster to refer to local file
  #source = "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"

}

locals {
  csv_data=file("${path.module}/config/instances.csv")
  instances=csvdecode(local.csv_data)
}

resource "libvirt_volume" "volume" {
  for_each = { for inst in local.instances : inst.hostname => inst}
  name           = "volume-${each.value.hostname}.qcow2"
  base_volume_id = libvirt_volume.base_volume.id
  pool = libvirt_pool.cluster.name
  size =  var.disksizeMB
}

resource "libvirt_volume" "nfs_volume" {
  name = "nfs_volume.qcow2"
  base_volume_id = libvirt_volume.base_volume.id
  pool = libvirt_pool.cluster.name
  size =  var.nfs_disksizeMB
}

resource "libvirt_volume" "nfs_data_volume" {
  name = "nfs_data_volume.qcow2"
  pool = libvirt_pool.cluster.name
  size =  var.nfs_data_disksizeMB
}
resource "libvirt_network" "management_network" {
  name = var.management_network
  mode      = "nat"
  autostart = true
  dhcp {
    enabled = true
  }  
  addresses = [var.management_address]

}

resource "libvirt_network" "provider_network" {
  name = var.provider_network
  mode      = "nat"
  autostart = true
  dhcp {
    enabled = false
  }  
  addresses = [var.provider_address]

}

# Use CloudInit to add the instance
resource "libvirt_cloudinit_disk" "commoninit" {
  for_each = { for inst in local.instances : inst.hostname => inst}
  name      = "${each.value.hostname}-commoninit.iso"
  pool = libvirt_pool.cluster.name
  user_data = data.template_file.user_data[each.value.hostname].rendered
  network_config = data.template_file.network_data[each.value.hostname].rendered
}

data "template_file" "network_data" {
  for_each = { for inst in local.instances : inst.hostname => inst}
  template = file("${path.module}/config/network_data.yaml")
  vars = {
    hostname = each.value.hostname
    management_ip = each.value.management_ip
    management_gateway = var.management_gateway
    management_dns = var.management_dns
    management_prefix = split("/",var.management_address)[1]
    provider_ip = each.value.provider_ip
    provider_gateway = var.provider_gateway
    provider_dns = var.provider_dns
    provider_prefix = split("/",var.provider_address)[1]
  }
}

data "template_file" "user_data" {
  for_each = { for inst in local.instances : inst.hostname => inst}
  template = file("${path.module}/config/${each.value.cloudinit}")
  vars = {
    hostname = each.value.hostname
    ssh_key = file(var.ssh_key)
    username = var.username
    crio_version = var.crio-version
    init_script = base64encode(file("${path.module}/scripts/init.sh"))
    install_crio_script = base64encode(file("${path.module}/scripts/install_crio.sh"))
    install_kube_script = base64encode(file("${path.module}/scripts/install_kube.sh"))
    kube_version = var.kube-version 
    k8s_admin_ssh_private_key = base64encode(file(var.k8s_admin_ssh_private_key))
    k8s_admin_ssh_public_key = file(var.k8s_admin_ssh_public_key)
    hosts = base64encode(join("\n", [for inst in local.instances : "${inst.management_ip} ${inst.hostname}"]))
    cluster_endpoint_hostfile = base64encode(join("",[for inst in local.instances : "${inst.management_ip} ${var.k8s_cluster_endpoint}" if length(regexall(".*control.*", inst.hostname)) > 0]))
    init_cluster_script = base64encode(file("${path.module}/scripts/init_cluster.sh"))
    concat_hostname_script = base64encode(file("${path.module}/scripts/concat_hostname.sh"))
    join_cluster_script = base64encode(file("${path.module}/scripts/join_cluster.sh"))
    install_cni_calico_script = base64encode(file("${path.module}/scripts/install_cni_calico.sh"))
    install_cni_cilium_script = base64encode(file("${path.module}/scripts/install_cni_cilium.sh"))
    install_containerd_script = base64encode(file("${path.module}/scripts/install_containerd.sh"))
    install_containerd_cni_script = base64encode(file("${path.module}/scripts/install_containerd_cni.sh"))
    install_loadbalancer_mlb_script = base64encode(file("${path.module}/scripts/install_loadbalancer_mlb.sh"))
    proxy_server = var.proxy_server
    password = file("${path.module}/config/.password")
    configure_proxy_script = base64encode(file("${path.module}/scripts/configure_proxy.sh"))
    metallb_addresspool_config = base64encode(file("${path.module}/config/metallb-addresspool.yaml"))
    wait_script = base64encode(file("${path.module}/scripts/wait.sh"))
    install_helm_script = base64encode(file("${path.module}/scripts/install_helm.sh"))
    cilium_version = var.cilium_version
    pod_cidr = var.pod_cidr
    custom_apt_conf = base64encode(file("${path.module}/config/custom-apt.conf"))
    install_nfs_server_script = base64encode(file("${path.module}/scripts/install_nfs_server.sh"))
    configure_nfs_provisioning_script = base64encode(file("${path.module}/scripts/configure_nfs_provisioning.sh"))
    nfs_server_path = var.nfs_server_path
    nfs_server_hostname = var.nfs_server_hostname
    nfs_server_ip = var.nfs_server_ip
    configure_nfs_nodes_script = base64encode(file("${path.module}/scripts/configure_nfs_nodes.sh"))
    loadbalancer_pool = var.loadbalancer_pool
  }
}

# Define KVM domain to create
resource "libvirt_domain" "domain" {
  for_each = { for inst in local.instances : inst.hostname => inst}
  name   = "k8s-${each.value.hostname}"
  memory     = var.memoryMB
  vcpu       = var.cpu
  qemu_agent = true
  autostart  = true

  cpu {
    mode = "host-model"
  }

  disk {
    volume_id = libvirt_volume.volume[each.value.hostname].id
  }

  cloudinit = libvirt_cloudinit_disk.commoninit[each.value.hostname].id

  network_interface {
    network_name = var.management_network
    hostname = each.value.hostname
    addresses = [each.value.management_ip]
  }

  network_interface {
    network_name = var.provider_network
    hostname = each.value.hostname
    addresses = [each.value.provider_ip]
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

  depends_on = [
    libvirt_network.management_network
  ]


}

resource "libvirt_cloudinit_disk" "nfs_commonit" {
  name = "nfs_commoninit.iso"
  pool = libvirt_pool.cluster.name
  user_data = data.template_file.nfs_user_data.rendered
  network_config = data.template_file.nfs_network_data.rendered

}

data "template_file" "nfs_network_data" {
  template = file("${path.module}/config/nfs_network_data.yaml")
  vars = {
    hostname = var.nfs_server_hostname
    management_ip = var.nfs_server_ip
    management_gateway = var.management_gateway
    management_dns = var.management_dns
    management_prefix = split("/", var.management_address)[1]
  }
}

data "template_file" "nfs_user_data" {
  template = file("${path.module}/config/cloud_init_nfs.yaml")
  vars = {
    hostname = var.nfs_server_hostname
    ssh_key = file(var.ssh_key)
    username = var.username
    hosts = base64encode(join("\n", [for inst in local.instances : "${inst.management_ip} ${inst.hostname}"]))
    cluster_endpoint_hostfile = base64encode(join("",[for inst in local.instances : "${inst.management_ip} ${var.k8s_cluster_endpoint}" if length(regexall(".*control.*", inst.hostname)) > 0]))
    concat_hostname_script = base64encode(file("${path.module}/scripts/concat_hostname.sh"))
    install_nfs_server_script = base64encode(file("${path.module}/scripts/install_nfs_server.sh"))
    proxy_server = var.proxy_server
    nfs_server_hostname = var.nfs_server_hostname
    nfs_server_ip = var.nfs_server_ip
    nfs_server_path = var.nfs_server_path
  }
}


resource "libvirt_domain" "nfs_domain" {
  name   = "nfs-server"
  memory     = var.nfs_memoryMB
  vcpu       = var.nfs_cpu
  qemu_agent = true
  autostart  = true

  cpu {
    mode = "host-model"
  }

  disk {
    volume_id = libvirt_volume.nfs_volume.id
  }

  disk {
    volume_id = libvirt_volume.nfs_data_volume.id  
  }

  cloudinit = libvirt_cloudinit_disk.nfs_commonit.id

  network_interface {
    network_name = var.management_network
    hostname = var.nfs_server_hostname
    addresses = [var.nfs_server_ip]
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

  depends_on = [
    libvirt_network.management_network
  ]


}

output "ips" {
  # show IP, run 'terraform refresh' if not populated
  value = [[for inst in local.instances : libvirt_domain.domain[inst.hostname].network_interface.0.addresses]
      ,libvirt_domain.nfs_domain.network_interface.0.addresses
  ]

  
}
