output "k3s_token" {
  description = "K3s cluster token"
  value = local.k3s_token
  sensitive = true
}

output "kubeconfig_command" {
  description = "Command to retrieve kubeconfig from control plane"
  value = "ssh root@${cidrhost(var.subnet, var.control_plane_first_num)} 'sudo cat /etc/rancher/k3s/k3s.yaml'"
}

output "cluster_info" {
  description = "K3s cluster information"
  value = {
    control_plane = {
      count = var.control_plane_count
      cpu = var.control_plane_cpu
      memory = var.control_plane_memory
      ips = [for i in range(var.control_plane_count) : cidrhost(var.subnet, var.control_plane_first_num + i)]
    }
    workers = {
      count = var.worker_count
      cpu = var.worker_cpu
      memory = var.worker_memory
      ips = [for i in range(var.worker_count) : cidrhost(var.subnet, var.worker_first_num + i)]
    }
    control_plane_external = {
      ip = hcloud_server.k3s_control_plane_external.ipv4_address
      server_type = hcloud_server.k3s_control_plane_external.server_type
      location = hcloud_server.k3s_control_plane_external.location
    }
    k3s_version = var.k3s_version
  }
}
