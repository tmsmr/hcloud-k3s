hcloud_server_node_type    = "cx11"
hcloud_agent_node_type     = "cx11"
hcloud_loadbalancer_type   = "lb11"
hcloud_location            = "nbg1"
hcloud_datacenter          = "nbg1-dc3"
hcloud_net_zone            = "eu-central"

server_node_count          = 2
agent_node_count           = 3

k3s_channel                = "v1.24"
upgrade_controller_version = "v0.9.1"
longhorn_version           = "v1.3.1"
certmanager_version        = "v1.9.1"
