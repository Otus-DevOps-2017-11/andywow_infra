locals {
  app_port_name       = "http"
  load_balancer_count = "${var.create_loadbalancer ? 1 : 0}"
}

# Instance group for load balanciing
resource "google_compute_instance_group" "app-group" {
  count       = "${local.load_balancer_count}"
  name        = "app-group"
  description = "app instance group"
  instances   = ["${var.instance_list}"]

  named_port {
    name = "${local.app_port_name}"
    port = "${var.app_port}"
  }

  zone = "${var.zone}"
}

# HTTP health check
resource "google_compute_http_health_check" "app-health-check" {
  count              = "${local.load_balancer_count}"
  name               = "app-health-check"
  check_interval_sec = 30
  port               = "${var.app_port}"
  request_path       = "/"
  timeout_sec        = 5
}

# Backend service
resource "google_compute_backend_service" "app-backend-service" {
  count            = "${local.load_balancer_count}"
  name             = "app-backend-service"
  port_name        = "${local.app_port_name}"
  protocol         = "HTTP"
  session_affinity = "CLIENT_IP"
  timeout_sec      = 10
  enable_cdn       = false

  backend {
    group = "${google_compute_instance_group.app-group.0.self_link}"
  }

  health_checks = ["${google_compute_http_health_check.app-health-check.0.self_link}"]
}

# URL mapping
# Compute Engine HTTP(S) Load Balancing allows you to direct traffic to different instances based on the incoming URL.
resource "google_compute_url_map" "app-url-map" {
  count = "${local.load_balancer_count}"
  name  = "app-url-map"

  default_service = "${google_compute_backend_service.app-backend-service.0.self_link}"
}

# Resource proxy
# Route incoming request to URL map
resource "google_compute_target_http_proxy" "app-resource-proxy" {
  count   = "${local.load_balancer_count}"
  name    = "app-resource-proxy"
  url_map = "${google_compute_url_map.app-url-map.0.self_link}"
}

# Forwarding rule
resource "google_compute_global_forwarding_rule" "app-forwarding-rule" {
  count      = "${local.load_balancer_count}"
  name       = "app-forwarding-rule"
  target     = "${google_compute_target_http_proxy.app-resource-proxy.0.self_link}"
  port_range = 80
}
