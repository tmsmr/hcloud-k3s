# NETWORK CONFIG

locals {
  k3s_net          = "10.10.0.0/16"
  k3s_nodes        = "10.10.10.0/24"
  k3s_nodes_prefix = "10.10.10"
}

# SEEDS

resource "random_string" "deployment_id" {
  length  = 8
  special = false
}

resource "random_string" "k3s_secret" {
  length  = 32
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
    direction  = "in"
    protocol   = "icmp"
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

module "hcloud_k3s_server_nodes" {
  count           = var.server_node_count
  source          = "./modules/hcloud-k3s-node"
  name            = "k3s-server-${count.index + 1}-${random_string.deployment_id.result}"
  clientkeys      = [module.hcloud_ssh_key.name]
  firewalls       = [hcloud_firewall.k3s_fw.id]
  dc              = var.hcloud_datacenter
  k3s_token       = random_string.k3s_secret.result
  k3s_private_ip  = "${local.k3s_nodes_prefix}.${count.index + 1}"
  k3s_is_master   = count.index == 0 ? true : false
  k3s_is_server   = true
  k3s_master      = "${local.k3s_nodes_prefix}.1"
  placement_group = hcloud_placement_group.node_placement_group.id
  network_id      = hcloud_network.k3s_net.id
}

resource "null_resource" "kubeconfigs" {
  count = var.server_node_count
  provisioner "local-exec" {
    command     = <<EOC
      while ! ./bin/ssh-k3s-server-1 "cat /root/k3s-admin.yaml &> /dev/null" &> /dev/null; do sleep 1; done
      ./bin/ssh-k3s-server-1 cat /root/k3s-admin.yaml > ./deployment/k3s-admin-server-${count.index + 1}.yaml
    EOC
    interpreter = ["bash", "-c"]
  }
  provisioner "local-exec" {
    when        = destroy
    command     = <<EOC
      rm ./deployment/k3s-admin-server-${count.index + 1}.yaml || true
    EOC
    interpreter = ["bash", "-c"]
  }
  depends_on = [module.hcloud_k3s_server_nodes]
}

resource "local_file" "kubectl_scripts" {
  count   = var.server_node_count
  content = templatefile("${path.root}/templates/kubectl.sh", {
    kubeconfig = "k3s-admin-server-${count.index + 1}.yaml"
  })
  filename        = "bin/kubectl-k3s-server-${count.index + 1}"
  file_permission = "700"
  depends_on      = [null_resource.kubeconfigs]
}


module "hcloud_k3s_agent_nodes" {
  count           = var.agent_node_count
  source          = "./modules/hcloud-k3s-node"
  name            = "k3s-agent-${count.index + 1}-${random_string.deployment_id.result}"
  clientkeys      = [module.hcloud_ssh_key.name]
  firewalls       = [hcloud_firewall.k3s_fw.id]
  dc              = var.hcloud_datacenter
  k3s_private_ip  = "${local.k3s_nodes_prefix}.${254 - count.index}"
  k3s_master      = "${local.k3s_nodes_prefix}.1"
  k3s_is_master   = false
  k3s_is_server   = false
  k3s_token       = random_string.k3s_secret.result
  placement_group = hcloud_placement_group.node_placement_group.id
  network_id      = hcloud_network.k3s_net.id
  depends_on      = [module.hcloud_k3s_server_nodes]
}

# SSH SCRIPTS/KEYS


resource "local_file" "known_hosts" {
  content         = join("", [for v in concat(module.hcloud_k3s_server_nodes.*, module.hcloud_k3s_agent_nodes.*) : "${v.node.ipv4_address} ${v.hostkey}"])
  filename        = "deployment/known_hosts"
  file_permission = "644"
}

resource "local_file" "client_priv_key" {
  content         = module.hcloud_ssh_key.private_key_pem
  filename        = "deployment/id_ecdsa"
  file_permission = "600"
}

resource "local_file" "ssh_script_servers" {
  count   = var.server_node_count
  content = templatefile("${path.root}/templates/ssh.sh", {
    node_ip = module.hcloud_k3s_server_nodes[count.index].node.ipv4_address
  })
  filename        = "bin/ssh-k3s-server-${count.index + 1}"
  file_permission = "700"
}

resource "local_file" "ssh_script_agents" {
  count   = var.agent_node_count
  content = templatefile("${path.root}/templates/ssh.sh", {
    node_ip = module.hcloud_k3s_agent_nodes[count.index].node.ipv4_address
  })
  filename        = "bin/ssh-k3s-agent-${count.index + 1}"
  file_permission = "700"
}
