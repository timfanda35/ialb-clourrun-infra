locals {
  ports = {
    prometheus = 9090
  }

  services = {
    prometheus-1 = {
      sa = google_service_account.sa-1.email
    }
    prometheus-2 = {
      sa = google_service_account.sa-2.email
    }
  }
}

resource "google_cloud_run_v2_service" "prometheus-1" {
  for_each = local.services

  name                 = each.key
  location             = var.region
  ingress              = "INGRESS_TRAFFIC_INTERNAL_ONLY"
  invoker_iam_disabled = true

  template {
    service_account = each.value.sa

    containers {
      image = "gke.gcr.io/prometheus-engine/frontend:v0.15.3-gke.0"

      args = [
        "--web.listen-address=:${local.ports.prometheus}",
        "--query.project-id=${var.project_id}"
      ]

      ports {
        container_port = local.ports.prometheus
      }

      startup_probe {
        initial_delay_seconds = 0
        timeout_seconds       = 1
        period_seconds        = 3
        failure_threshold     = 1
        tcp_socket {
          port = local.ports.prometheus
        }
      }

      liveness_probe {
        http_get {
          path = "/-/healthy"
        }
      }
    }
  }

  depends_on          = [google_service_account.sa-1]
  deletion_protection = false
}
