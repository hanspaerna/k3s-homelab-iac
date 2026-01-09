terraform {
  required_version = "~> 1.11.0"
  required_providers {
    hcloud = {
      source = "opentofu/hcloud"
      version = "1.57.0"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

# persistent Hetzner Primary IP that survives infrastructure destroys
resource "hcloud_primary_ip" "primary_ip_k3s_ext" {
  name = "primary_ip_k3s_ext"
  type = "ipv4"
  assignee_type = "server"
  datacenter = "nbg1-dc3"
  auto_delete = false

  lifecycle {
    prevent_destroy = true
  }
}
