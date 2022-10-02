resource "hcloud_load_balancer" "load_balancer" {
  name               = "k3s-lb-${random_string.deployment_id.result}"
  load_balancer_type = var.hcloud_loadbalancer_type
  location           = var.hcloud_location
}

resource "hcloud_load_balancer_network" "lb_net_attachmant" {
  load_balancer_id = hcloud_load_balancer.load_balancer.id
  network_id       = hcloud_network.cluster_net.id
  ip               = "${local.k3s_nodes_prefix}.254"
}

resource "hcloud_load_balancer_target" "load_balancer_targets" {
  type             = "label_selector"
  load_balancer_id = hcloud_load_balancer.load_balancer.id
  label_selector   = "k3s_type in (server,agent)"
  use_private_ip   = true
  depends_on       = [hcloud_load_balancer_network.lb_net_attachmant]
}

resource "hcloud_load_balancer_service" "load_balancer_http_service" {
  load_balancer_id = hcloud_load_balancer.load_balancer.id
  protocol         = "tcp"
  proxyprotocol    = true
  listen_port = 80
  destination_port = 80
}

resource "hcloud_load_balancer_service" "load_balancer_https_service" {
  load_balancer_id = hcloud_load_balancer.load_balancer.id
  protocol         = "tcp"
  proxyprotocol    = true
  listen_port = 443
  destination_port = 443
}
