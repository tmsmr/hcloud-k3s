variable "name" {
  default = "k3s-node"
}

variable "type" {
  default = "cx11"
}

variable "image" {
  default = "debian-11"
}

variable "placement_group" {}

variable "dc" {}

variable "clientkeys" {
  default = []
}

variable "firewalls" {
  default = []
}

variable "k3s_is_master" {}

variable "k3s_is_server" {}

variable "k3s_token" {}

variable "k3s_master" {}

variable "k3s_private_ip" {}

variable "network_id" {}
