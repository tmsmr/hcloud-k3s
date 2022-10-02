variable "hcloud_apikey" {
  description = "Hetzer Cloud API key to use"
}

variable "hcloud_server_node_type" {
  description = "Node type for the K3s servers"
}

variable "hcloud_agent_node_type" {
  description = "Node type for the K3s agents"
}

variable "hcloud_loadbalancer_type" {
  description = "Node type for the Load Balancer"
}

variable "hcloud_location" {
  description = "Hetzner Cloud location (e.g. nbg1)"
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
    condition     = var.server_node_count > 0
    error_message = "you need at least 1 server"
  }
}

variable "agent_node_count" {
  description = "Number of K3s agent nodes"
}

variable "k3s_channel" {
  description = "K3s version channel (https://github.com/k3s-io/k3s/blob/master/channel.yaml)"
}

variable "upgrade_controller_version" {
  description = "Version of https://github.com/rancher/system-upgrade-controller"
}

variable "longhorn_version" {
  description = "Version of https://github.com/longhorn/longhorn"
}

variable "k8s_dashboard_version" {
  description = "Version of https://github.com/kubernetes/dashboard"
}

variable "k3s_cluster_cidr" {
  description = "CIDR for pod IP's"
}

variable "hcloud_managed_cert_domains" {
  description = "List of Domains (e.g. ['*.example.com', 'example.com']) for which the LB will issue Certificates for"
}
