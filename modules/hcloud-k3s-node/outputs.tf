output "node" {
  value = hcloud_server.k3s_node
}

output "hostkey" {
  value = tls_private_key.keypair.public_key_openssh
}
