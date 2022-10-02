variable "name" {
  description = "Name of the node (Hostname and k3s node name)"
}

variable "image" {
  default = "debian-11"
}

variable "type" {
  default     = "cx11"
  description = "Server type of the node"
}

variable "dc" {
  description = "Datacenter identifier"
}

variable "placement_group" {
  description = "Placement group for the node"
}

variable "clientkeys" {
  default     = []
  description = "Names of SSH-keys for client connections"
}

variable "firewalls" {
  default     = []
  description = "ID's of firewalls to apply"
}

variable "network_id" {
  description = "ID of the private network to attach to"
}

variable "private_ip" {
  description = "Static IP for the private network NIC"
}

variable "k3s_channel" {
  description = "K3s version channel (https://github.com/k3s-io/k3s/blob/master/channel.yaml)"
}

variable "k3s_is_server" {
  default     = false
  description = "Whether to install this node as K3s server or not"
}

variable "k3s_is_initial" {
  default     = false
  description = "Initialize the K3s cluster with this node"
}

variable "k3s_initial_ip" {
  description = "IP/Hostname of the initial server of the K3s cluster"
}

variable "k3s_token" {
  description = "K3s secret token"
}

variable "trusted_proxy" {
  description = "IP of the LB to be trusted"
}
