variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type = string
  default = "https://<YOUR_PROXMOX_HOST>:8006/api2/json"
}

variable "proxmox_username" {
  description = "Proxmox username (Passthrough of raw PCIe devices requires root)"
  type = string
  default = "root@pam"
}

variable "proxmox_password" {
  description = "Proxmox password"
  type = string
  sensitive = true
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type = string
  default = "YOUR_SSH_PUBLIC_KEY_HERE"
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type = string
  default = "proxmox"
}

variable "template_id" {
  description = "VM template name for cloning"
  type = string
  default = "ubuntu-24.04-cloud-tpl"
}

variable "vm_id_start" {
  description = "Starting VM ID for created VMs"
  type = number
  default = 30000
}

variable "storage" {
  description = "Storage pool for VM disks"
  type = string
  default = "local-zfs"
}

variable "subnet" {
  description = "Subnet (incl. bit mask)"
  type = string
  default = "192.168.1.0/24"
}

variable "bridge" {
  description = "Network bridge"
  type = string
  default = "vmbr0"
}

variable "gateway" {
  description = "Network gateway"
  type = string
  default = "192.168.1.1"
}

variable "nameserver" {
  description = "DNS nameserver"
  type = string
  default = "192.168.1.1"
}

variable "searchdomain" {
  description = "DNS search domain"
  type = string
  default = "local"
}

# Control Plane Configuration
variable "control_plane_count" {
  description = "Number of control plane nodes"
  type = number
  default = 1
}

variable "control_plane_cpu" {
  description = "CPU cores for control plane nodes"
  type = number
  default = 2
}

variable "control_plane_memory" {
  description = "Memory in MB for control plane nodes"
  type = number
  default = 4096
}

variable "control_plane_disk_size" {
  description = "Disk size for control plane nodes"
  type = string
  default = "10G"
}

variable "control_plane_ip_start" {
  description = "Starting IP for control plane nodes"
  type = string
  default = "192.168.1.180"
}

variable "control_plane_first_num" {
  description = "A starting number in a subnet"
  type = number
  default = 180
}

# Worker Configuration
variable "worker_count" {
  description = "Number of worker nodes"
  type = number
  default = 3
}

variable "worker_cpu" {
  description = "CPU cores for worker nodes"
  type = number
  default = 1
}

variable "worker_memory" {
  description = "Memory in MB for worker nodes"
  type = number
  default = 2048
}

variable "worker_disk_size" {
  description = "Disk size for worker nodes"
  type = string
  default = "10G"
}

variable "worker_ip_start" {
  description = "Starting IP for worker nodes"
  type = string
  default = "192.168.1.185"
}

variable "worker_first_num" {
  description = "A starting number in a subnet"
  type = number
  default = 185
}

variable "igpu_pcie_id" {
  description = "PCIe ID of Intel iGPU for passthrough"
  type = string
  default = "0000:00:02.0"
}

# K3s Configuration
variable "k3s_version" {
  description = "K3s version to install"
  type = string
  default = "v1.34.1+k3s1"
}

variable "k3s_token" {
  description = "K3s cluster token (will be auto-generated if not provided)"
  type = string
  default = ""
  sensitive = true
}

variable "cloud_init_username" {
  description = "A service user that is used by Cloud-Init"  
  type = string
  default = "debian"
  sensitive = false
}

variable "cloud_init_password" {
  description = "A password of the service user that is used by Cloud-Init"
  type = string
  default = "debian"
  sensitive = true
}

variable "hcloud_token" {
  description = "A token for Hetzner Cloud"
  sensitive = true
}

variable "github_username" {
  description = "A username for Github"
  sensitive = false
}

variable "github_token" {
  description = "A read-write token for GitHub"
  sensitive = true
}
