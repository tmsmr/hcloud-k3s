# hcloud-k3s
*From 0 to `kubectl` in < 5 min, heavily WiP!*

## Requirements
- A Hetzner Cloud account
- Terraform (Tested with v1.2.6)
- `bash`
- (`kubectl`)

## Quickstart
- Generate Hetzner Cloud project + API-Key
- Adjust config in `config.auto.tfvars`
- `terraform init && terraform apply`

## Utilities
- Access nodes with `bin/ssh-...`
- Interact with cluster using `bin/kubectl`
