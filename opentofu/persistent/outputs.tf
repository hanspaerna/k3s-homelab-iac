output "primary_ip_id" {
  description = "ID of the primary IP for external K3s control plane"
  value = hcloud_primary_ip.primary_ip_k3s_ext.id
}

output "primary_ip_address" {
  description = "The actual IPv4 address"
  value = hcloud_primary_ip.primary_ip_k3s_ext.ip_address
}
