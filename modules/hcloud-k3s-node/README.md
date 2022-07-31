# hcloud-k3s-node

*Installs K3s on a Debian 11 host using cloud-init*

## Random notes
- Not suitable to use as stand-alone module, needs various mandatory config variables
- `unattended-upgrades` are enabled, but without automatic reboots
- Terraform-generated SSH host key for initial trust

## `outputs`
- `ip`: IP of the node
- `hostkey`: SSH public host key in PEM format - ECDSA (P521)
