output "private_key_pem" {
  value = tls_private_key.keypair.private_key_pem
}

output "name" {
  value = var.name
}
