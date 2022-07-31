resource "tls_private_key" "keypair" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}

resource "hcloud_server" "k3s_node" {
  name         = var.name
  image        = var.image
  server_type  = var.type
  datacenter   = var.dc
  ssh_keys     = var.clientkeys
  firewall_ids = var.firewalls
  placement_group_id = var.placement_group
  network {
    network_id = var.network_id
    ip = var.k3s_private_ip
  }
  user_data = templatefile( "${path.module}/templates/user_data.yaml", {
    host_ecdsa_private        = indent(4, tls_private_key.keypair.private_key_pem)
    host_ecdsa_public         = tls_private_key.keypair.public_key_openssh
    k3s_master = var.k3s_master
    k3s_token = var.k3s_token
    k3s_is_server = var.k3s_is_server
    k3s_is_master = var.k3s_is_master
    k3s_private_ip = var.k3s_private_ip
    node_name = var.name
  })
}
