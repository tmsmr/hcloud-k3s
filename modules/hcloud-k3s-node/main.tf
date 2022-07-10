resource "tls_private_key" "keypair" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}

locals {
  user_data_templ = var.k3s_is_server == true ? "${path.module}/templates/user_data_server.yaml" : "${path.module}/templates/user_data_agent.yaml"
}

resource "hcloud_server" "k3s_node" {
  name         = var.name
  image        = var.image
  server_type  = var.type
  datacenter   = var.dc
  ssh_keys     = var.clientkeys
  firewall_ids = var.firewalls
  placement_group_id = var.placement_group
  user_data = templatefile( local.user_data_templ, {
    host_ecdsa_private        = indent(4, tls_private_key.keypair.private_key_pem)
    host_ecdsa_public         = tls_private_key.keypair.public_key_openssh
    k3s_server = var.k3s_server
    k3s_secret = var.k3s_secret
    node_name = var.name
  })
}
