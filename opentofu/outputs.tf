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
    k3s_version = var.k3s_version
  }
}
