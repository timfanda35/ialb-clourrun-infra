data "google_compute_network" "demo" {
  name = "demo"
}

data "google_compute_subnetwork" "demo-gke-node" {
  name = "demo-gke-node"
}

resource "google_compute_firewall" "allow-grafana" {
  name    = "allow-grafana"
  network = data.google_compute_network.demo.name

  target_tags = [ "allow-grafana" ]

  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }

  source_ranges = ["${var.my-ip}/32"]
}
