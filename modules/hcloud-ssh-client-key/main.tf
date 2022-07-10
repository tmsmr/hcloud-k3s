resource "tls_private_key" "keypair" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}

resource "hcloud_ssh_key" "pubkey" {
  name       = var.name
  public_key = tls_private_key.keypair.public_key_openssh
}
