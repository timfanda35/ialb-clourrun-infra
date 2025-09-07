resource "google_compute_instance" "console-01" {
  name         = "console-01"
  machine_type = "e2-micro"
  zone         = "asia-east1-b"
  tags         = ["allow-grafana"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = 50
    }
  }

  network_interface {
    network    = data.google_compute_network.demo.self_link
    subnetwork = data.google_compute_subnetwork.demo-gke-node.self_link

    access_config {}
  }

  service_account {
    scopes = ["compute-rw", "storage-ro", "monitoring-write", "logging-write", "cloud-platform"]
    email  = google_service_account.gce-sa.email
  }

  depends_on = [google_service_account.gce-sa]

  lifecycle {
    ignore_changes = [
      metadata,
    ]
  }
}
