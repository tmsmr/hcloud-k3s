resource "random_string" "deployment_id" {
  length  = 8
  special = false
}

resource "random_string" "k3s_token" {
  length  = 32
  special = false
}

module "hcloud_ssh_key" {
  source = "./modules/hcloud-ssh-client-key"
  name   = "k3s-${random_string.deployment_id.result}"
}

resource "hcloud_placement_group" "node_placement_group" {
  name = "k3s-${random_string.deployment_id.result}"
  type = "spread"
}

module "hcloud_k3s_server_nodes" {
  count           = var.server_node_count
  source          = "./modules/hcloud-k3s-node"
  name            = "k3s-server-${count.index + 1}-${random_string.deployment_id.result}"
  type            = var.hcloud_server_node_type
  dc              = var.hcloud_datacenter
  placement_group = hcloud_placement_group.node_placement_group.id
  clientkeys      = [module.hcloud_ssh_key.name]
  firewalls       = [hcloud_firewall.k3s_fw.id]
  network_id      = hcloud_network.cluster_net.id
  private_ip      = "${local.k3s_nodes_prefix}.${count.index + 1}"
  k3s_is_server   = true
  k3s_is_initial  = count.index == 0 ? true : false
  k3s_initial_ip  = "${local.k3s_nodes_prefix}.1"
  k3s_token       = random_string.k3s_token.result
  trusted_proxy   = "${local.k3s_nodes_prefix}.254"
  k3s_channel     = var.k3s_channel
}

module "hcloud_k3s_agent_nodes" {
  count           = var.agent_node_count
  source          = "./modules/hcloud-k3s-node"
  name            = "k3s-agent-${count.index + 1}-${random_string.deployment_id.result}"
  type            = var.hcloud_agent_node_type
  dc              = var.hcloud_datacenter
  placement_group = hcloud_placement_group.node_placement_group.id
  clientkeys      = [module.hcloud_ssh_key.name]
  firewalls       = [hcloud_firewall.k3s_fw.id]
  network_id      = hcloud_network.cluster_net.id
  depends_on      = [module.hcloud_k3s_server_nodes]
  private_ip      = "${local.k3s_nodes_prefix}.${254 - 1 - count.index}"
  k3s_initial_ip  = "${local.k3s_nodes_prefix}.1"
  k3s_token       = random_string.k3s_token.result
  trusted_proxy   = "${local.k3s_nodes_prefix}.254"
  k3s_channel     = var.k3s_channel
}
