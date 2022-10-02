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

resource "hcloud_managed_certificate" "load_balancer_managed_cert" {
  name         = "managed_cert"
  domain_names = ["*.tmsmr.de", "tmsmr.de"]
}

resource "hcloud_load_balancer_service" "load_balancer_https_service" {
  load_balancer_id = hcloud_load_balancer.load_balancer.id
  protocol         = "https"
  proxyprotocol    = true
  destination_port = 80
  http {
    redirect_http = true
    certificates  = [hcloud_managed_certificate.load_balancer_managed_cert.id]
  }
  health_check {
    interval = 15
    port     = 80
    protocol = "http"
    timeout  = 5
    http {
      path = "/"
      status_codes = ["2??", "3??", "4??"]
    }
  }
}
