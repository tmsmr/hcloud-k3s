variable "hcloud_apikey" {
  description = "Hetzer Cloud API key to use"
}

variable "hcloud_server_node_type" {
  description = "Node type for the K3s servers"
}

variable "hcloud_agent_node_type" {
  description = "Node type for the K3s agents"
}

variable "hcloud_datacenter" {
  description = "Hetzner Cloud datacenter (e.g. nbg1-dc3)"
}

variable "hcloud_net_zone" {
  description = "Network zone for private network (e.g. eu-central)"
}

variable "server_node_count" {
  description = "Number of K3s server nodes"
  validation {
    condition = var.server_node_count > 0
    error_message = "you need at least 1 server"
  }
}

variable "agent_node_count" {
  description = "Number of K3s agent nodes"
}
