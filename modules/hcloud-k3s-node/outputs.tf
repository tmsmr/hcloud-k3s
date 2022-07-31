output "ip" {
  value = hcloud_server.k3s_node.ipv4_address
}

output "hostkey" {
  value = tls_private_key.host_keypair.public_key_openssh
}
