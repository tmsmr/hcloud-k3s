# NETWORK CONFIG

locals {
  k3s_net = "10.10.10.0/24"
  k3s_nodes = "10.10.10.0/24"
  k3s_server = "10.10.10.254"
  k3s_agents_prefix = "10.10.10."
}

# SEEDS

resource "random_string" "deployment_id" {
  length  = 8
  special = false
}

resource "random_string" "k3s_secret" {
  length = 32
  special = false
}

# FIREWALL

resource "hcloud_firewall" "k3s_fw" {
  name = "k3s-${random_string.deployment_id.result}"
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = [
      "0.0.0.0/0"
    ]
  }
  rule {
    direction = "in"
    protocol = "icmp"
    source_ips = [
      "0.0.0.0/0"
    ]
  }
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = 6443
    source_ips = [
      "0.0.0.0/0"
    ]
  }
}

# PRIVATE NETWORK

resource "hcloud_network" "k3s_net" {
  name     = "k3s-${random_string.deployment_id.result}"
  ip_range = local.k3s_net
}
resource "hcloud_network_subnet" "k3s_nodes" {
  network_id   = hcloud_network.k3s_net.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = local.k3s_nodes
}

# SSH CLIENT KEY

module "hcloud_ssh_key" {
  source = "./modules/hcloud-ssh-client-key"
  name   = "k3s-${random_string.deployment_id.result}"
}

# NODES

resource "hcloud_placement_group" "node_placement_group" {
  name = "k3s-${random_string.deployment_id.result}"
  type = "spread"
}

module "hcloud_k3s_server_node" {
  source = "./modules/hcloud-k3s-node"
  name = "k3s-server-${random_string.deployment_id.result}"
  clientkeys = [module.hcloud_ssh_key.name]
  firewalls = [hcloud_firewall.k3s_fw.id]
  dc = var.hcloud_datacenter
  k3s_secret = random_string.k3s_secret.result
  k3s_is_server = true
  k3s_server = local.k3s_server
  placement_group = hcloud_placement_group.node_placement_group.id
}

resource "hcloud_server_network" "k3s_server_net_attachment" {
  server_id  = module.hcloud_k3s_server_node.node.id
  network_id = hcloud_network.k3s_net.id
  ip         = local.k3s_server
}

module "hcloud_k3s_agent_nodes" {
  count = var.agent_node_count
  source = "./modules/hcloud-k3s-node"
  name = "k3s-agent-${count.index + 1}-${random_string.deployment_id.result}"
  clientkeys = [module.hcloud_ssh_key.name]
  firewalls = [hcloud_firewall.k3s_fw.id]
  dc = var.hcloud_datacenter
  k3s_is_server = false
  k3s_server = local.k3s_server
  k3s_secret = random_string.k3s_secret.result
  placement_group = hcloud_placement_group.node_placement_group.id
}

resource "hcloud_server_network" "k3s_agent_net_attachments" {
  count = var.agent_node_count
  server_id  = module.hcloud_k3s_agent_nodes[count.index].node.id
  network_id = hcloud_network.k3s_net.id
  ip         = "${local.k3s_agents_prefix}${count.index + 2}"
}

# SSH SCRIPTS/KEYS


resource "local_file" "known_hosts" {
  content = join("", [for v in concat([module.hcloud_k3s_server_node], module.hcloud_k3s_agent_nodes.*) : "${v.node.ipv4_address} ${v.hostkey}"])
  filename = "deployment/known_hosts"
  file_permission = "644"
}

resource "local_file" "client_priv_key" {
  content         = module.hcloud_ssh_key.private_key_pem
  filename        = "deployment/id_ecdsa"
  file_permission = "600"
}

resource "local_file" "ssh_script_server" {
  content         = templatefile("${path.root}/templates/ssh.sh", {
    node_ip = module.hcloud_k3s_server_node.node.ipv4_address
  })
  filename        = "bin/ssh-k3s-server"
  file_permission = "700"
}

resource "local_file" "ssh_script_agents" {
  count = var.agent_node_count
  content         = templatefile("${path.root}/templates/ssh.sh", {
    node_ip = module.hcloud_k3s_agent_nodes[count.index].node.ipv4_address
  })
  filename        = "bin/ssh-k3s-agent-${count.index + 1}"
  file_permission = "700"
}
