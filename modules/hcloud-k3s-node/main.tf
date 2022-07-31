resource "tls_private_key" "host_keypair" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}

resource "hcloud_server" "k3s_node" {
  name               = var.name
  image              = var.image
  server_type        = var.type
  datacenter         = var.dc
  placement_group_id = var.placement_group
  ssh_keys           = var.clientkeys
  firewall_ids       = var.firewalls
  network {
    network_id = var.network_id
    ip         = var.private_ip
  }
  user_data = templatefile("${path.module}/templates/user_data.yaml", {
    k3s_node_name      = var.name
    host_ecdsa_private = indent(4, tls_private_key.host_keypair.private_key_pem)
    host_ecdsa_public  = tls_private_key.host_keypair.public_key_openssh
    k3s_private_ip     = var.private_ip
    k3s_is_server      = var.k3s_is_server
    k3s_is_initial     = var.k3s_is_initial
    k3s_initial_ip     = var.k3s_initial_ip
    k3s_token          = var.k3s_token
  })
}
