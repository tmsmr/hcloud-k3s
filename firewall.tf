resource "hcloud_firewall" "k3s_fw" {
  name = "k3s-${random_string.deployment_id.result}"
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "0.0.0.0/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = 6443
    source_ips = [
      "0.0.0.0/0"
    ]
  }
}
