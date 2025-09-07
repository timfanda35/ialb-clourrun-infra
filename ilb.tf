resource "google_compute_health_check" "hc-80" {
  name = "hc-80"
  http_health_check {
    port = 80
  }
}

# Backend Service

resource "google_compute_region_backend_service" "blackhole" {
  name                  = "blackhole"
  protocol              = "HTTP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  region                = var.region

  health_checks = [google_compute_health_check.hc-80.self_link]

  log_config {
    enable      = true
    sample_rate = 1
  }
}

resource "google_compute_region_backend_service" "serverless" {
  name                  = "serverless"
  protocol              = "HTTP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  region                = var.region

  log_config {
    enable      = true
    sample_rate = 1
  }

  backend {
    group = google_compute_region_network_endpoint_group.serverless-neg.self_link
  }
}

resource "google_compute_region_network_endpoint_group" "serverless-neg" {
  name                  = "serverless-neg"
  region                = var.region
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    url_mask = "${var.hostname}/<service>"
  }
}

# URL map
resource "google_compute_region_url_map" "default" {
  name            = "l7-ilb-regional-url-map"
  provider        = google-beta
  region          = var.region
  default_service = google_compute_region_backend_service.blackhole.self_link

  host_rule {
    hosts        = ["${var.hostname}"]
    path_matcher = "prometheus"
  }

  path_matcher {
    name            = "prometheus"
    default_service = google_compute_region_backend_service.blackhole.self_link

    route_rules {
      priority = 1
      service  = google_compute_region_backend_service.serverless.self_link
      match_rules {
        path_template_match = "/{service=*}/{path=**}"
      }
      route_action {
        url_rewrite {
          path_template_rewrite = "/{path}"
        }
      }
    }
  }
}

# HTTP target proxy
resource "google_compute_region_target_http_proxy" "default" {
  name     = "l7-ilb-target-http-proxy"
  provider = google-beta
  region   = var.region
  url_map  = google_compute_region_url_map.default.self_link
}

# forwarding rule
resource "google_compute_forwarding_rule" "google_compute_forwarding_rule" {
  name                  = "l7-ilb-forwarding-rule"
  provider              = google-beta
  region                = var.region
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.default.id
  network               = data.google_compute_network.demo.self_link
  subnetwork            = data.google_compute_subnetwork.demo-gke-node.self_link
  network_tier          = "PREMIUM"
}
