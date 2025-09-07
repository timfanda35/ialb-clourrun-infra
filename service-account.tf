resource "google_service_account" "sa-1" {
  account_id  = "monitoring-sa1"
  display_name = "monitoring-sa1"
}

resource "google_service_account" "sa-2" {
  account_id  = "monitoring-sa2"
  display_name = "monitoring-sa2"
}

resource "google_project_iam_binding" "metric-viewer-binding" {
  project = var.project_id
  role    = "roles/monitoring.viewer"

  members = [
    "serviceAccount:${google_service_account.sa-1.email}",
    "serviceAccount:${google_service_account.sa-2.email}",
  ]
}

# GCE

resource "google_service_account" "gce-sa" {
  account_id   = "gce-sa"
  display_name = "gce-sa"
}


resource "google_project_iam_binding" "logger-writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"

  members = [
    google_service_account.gce-sa.member
  ]
}

resource "google_project_iam_binding" "metric-writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"

  members = [
    google_service_account.gce-sa.member,
    "serviceAccount:${google_service_account.sa-1.email}",
    "serviceAccount:${google_service_account.sa-2.email}",
  ]
}
