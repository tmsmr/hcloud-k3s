output "name" {
  value = var.name
}

output "private_key_pem" {
  value = tls_private_key.keypair.private_key_pem
}
