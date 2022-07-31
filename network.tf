locals {
  cluster_net      = "10.10.0.0/16"
  k3s_subnet       = "10.10.10.0/24"
  k3s_nodes_prefix = "10.10.10"
}

resource "hcloud_network" "cluster_net" {
  name     = "k3s-${random_string.deployment_id.result}"
  ip_range = local.cluster_net
}

resource "hcloud_network_subnet" "k3s_subnet" {
  network_id   = hcloud_network.cluster_net.id
  type         = "cloud"
  network_zone = var.hcloud_net_zone
  ip_range     = local.k3s_subnet
}
