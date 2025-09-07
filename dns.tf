resource "google_dns_managed_zone" "my-prometheus-zone" {
  name     = "my-prometheus-zone"
  dns_name = "${var.hostname}."
  visibility = "private"

  private_visibility_config {
    networks {
      network_url = data.google_compute_network.demo.self_link
    }
  }
}

resource "google_dns_record_set" "my-prometheus-a-record" {
  name         = "${var.hostname}."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.my-prometheus-zone.name
  rrdatas      = [google_compute_forwarding_rule.google_compute_forwarding_rule.ip_address]
}
