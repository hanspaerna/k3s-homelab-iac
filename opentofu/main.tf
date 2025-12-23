terraform {
  required_version = "~> 1.11.0"
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.2-rc07"
    }

    random = {
      source = "hashicorp/random"
      version = "3.7.2"
    }

    local = {
      source = "hashicorp/local"
      version = "2.6.1"
    }

    hcloud = {
      source = "opentofu/hcloud"
      version = "1.57.0"
    }
  }
}

provider "proxmox" {
  pm_api_url = var.proxmox_api_url
  pm_api_token_id = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure = true
  
  pm_log_enable = true 
  pm_log_file = "../logs/terraform-plugin-proxmox.log"  
  pm_log_levels = {
    _default = "debug"
    _capturelog = ""
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

# Generate random token for K3s cluster
resource "random_password" "k3s_token" {
  length  = 32
  special = false
}

locals {
  k3s_token = var.k3s_token != "" ? var.k3s_token : random_password.k3s_token.result
}

# Control Plane Nodes
resource "proxmox_vm_qemu" "k3s_control_plane" {
  count = var.control_plane_count

  name = "k3s-cp-${count.index + 1}"
  target_node = var.proxmox_node
  clone = var.template_id
  full_clone = true
  vmid = var.vm_id_start + count.index

  agent = 1
  os_type = "cloud-init"
  memory = var.control_plane_memory

  cpu {
    type = "host"
    cores = var.control_plane_cpu
    sockets = 1
  }

  scsihw = "virtio-scsi-single"
  bootdisk = "scsi0"

  start_at_node_boot = true
  startup_shutdown {
    order = 1
  }

  disks {
    scsi {
      scsi0 {
        disk {
          storage = var.storage
          size = var.control_plane_disk_size
        }
      }
    }
    # CloudInit drive
    ide {
      ide2 {
        cloudinit {
          storage = var.storage
        }
      }
    }
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = var.bridge
  }

  # Serial port for console access
  serial {
    id   = 0
    type = "socket"
  }
  
  ipconfig0 = "ip=${cidrhost(var.subnet, var.control_plane_first_num + count.index)}/24,gw=${var.gateway}"

  nameserver = var.nameserver
  searchdomain = var.searchdomain

  ciuser = var.cloud_init_username
  cipassword = var.cloud_init_password
  sshkeys = var.ssh_public_key

  lifecycle {
    ignore_changes = [
      network,
      ciuser,
      sshkeys,
    ]
  }
}

# Worker Nodes
resource "proxmox_vm_qemu" "k3s_worker" {
  count = var.worker_count

  name = "k3s-worker-${count.index + 1}"
  target_node = var.proxmox_node
  clone = var.template_id
  full_clone = true
  vmid = var.vm_id_start + var.control_plane_count + count.index

  agent = 1
  os_type = "cloud-init"
  memory = var.worker_memory

  cpu {
    type = "host"
    cores = var.worker_cpu
    sockets = 1
  }

  scsihw = "virtio-scsi-single"
  bootdisk = "scsi0"

  start_at_node_boot = true
  startup_shutdown {
    order = 2
  }

  disks {
    scsi {
      scsi0 {
        disk {
          storage = var.storage
          size = var.worker_disk_size
        }
      }
    }
    # CloudInit drive
    ide {
      ide2 {
        cloudinit {
          storage = var.storage
        }
      }
    }
  }

  network {
    id = 0
    model = "virtio"
    bridge = var.bridge
  }

  # Serial port for console access
  serial {
    id = 0
    type = "socket"
  }

  ipconfig0 = "ip=${cidrhost(var.subnet, var.worker_first_num + count.index)}/24,gw=${var.gateway}"

  nameserver   = var.nameserver
  searchdomain = var.searchdomain

  ciuser     = var.cloud_init_username
  cipassword = var.cloud_init_password
  sshkeys    = var.ssh_public_key

  lifecycle {
    ignore_changes = [
      network,
      ciuser,
      sshkeys,
    ]
  }

  depends_on = [proxmox_vm_qemu.k3s_control_plane]
}

resource "hcloud_ssh_key" "main" {
  name       = "tofu-key"
  public_key = var.ssh_public_key
}

resource "hcloud_primary_ip" "primary_ip_k3s_ext" {
  name = "primary_ip_k3s_ext"
  type= "ipv4"
  assignee_type = "server"
  datacenter = "nbg1-dc3"
  auto_delete = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "hcloud_server" "k3s_control_plane_external" {
  name = "k3s-control-plane-external"
  image = "debian-13"
  server_type = "cx23"
  datacenter = "nbg1-dc3"
  ssh_keys = [
    "tofu-key"
  ]
  
  public_net {
    ipv4_enabled = true
    ipv4 = hcloud_primary_ip.primary_ip_k3s_ext.id
    ipv6_enabled = true
  }

  lifecycle {
    ignore_changes = [
      ssh_keys
    ]
  }
}

resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tmpl",
    {
      k3s_version = var.k3s_version
      k3s_token = local.k3s_token
      github_username = var.github_username
      github_token = var.github_token
      cloud_init_username = var.cloud_init_username
      control_plane_hostnames = [for vm in proxmox_vm_qemu.k3s_control_plane : vm.name]
      control_plane_ips = [for i in range(var.control_plane_count) : cidrhost(var.subnet, var.control_plane_first_num + i)]
      worker_hostnames = [for vm in proxmox_vm_qemu.k3s_worker : vm.name] 
      worker_ips = [for i in range(var.worker_count) : cidrhost(var.subnet, var.worker_first_num + i)]
      control_plane_external_hostname = hcloud_server.k3s_control_plane_external.name
      control_plane_external_ip = hcloud_server.k3s_control_plane_external.ipv4_address
    }
  )
  filename = "../ansible/inventory.tf.yml"
}
