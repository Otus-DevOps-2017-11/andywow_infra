# Google provider settings
provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

locals {
  app_port_name = "http"
}

# module for dynamic key count
module "userkeymodule" {
  source            = "./modules/userkeymodule"
  users_public_keys = "${var.users_public_keys}"
}

# Puma services temlate
data "template_file" "puma_service" {
  template = "${file("./files/puma.service.tpl")}"

  vars {
    app_port = "${var.app_port}"
  }
}

# Firewall settings
resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["${var.app_port}"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}

# Project metadata settings
resource "google_compute_project_metadata" "default" {
  metadata {
    ssh-keys = "${module.userkeymodule.ssh-keys-string}"
  }
}

# Reddit instance settings
resource "google_compute_instance" "reddit-app" {
  count        = "${var.instance_count}"
  name         = "reddit-app-${count.index}"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["reddit-app"]

  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  metadata {
    sshKeys = "appuser:${file(var.public_key_path)}"
  }

  network_interface {
    network       = "default"
    access_config = {}
  }

  connection {
    type        = "ssh"
    user        = "appuser"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "file" {
    content     = "${data.template_file.puma_service.rendered}"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}

# Instance group for load balanciing
resource "google_compute_instance_group" "reddit-app-group" {
  name        = "reddit-app-group"
  description = "reddit-app instance group"
  instances   = ["${google_compute_instance.reddit-app.*.self_link}"]

  named_port {
    name = "${local.app_port_name}"
    port = "${var.app_port}"
  }

  zone = "${var.zone}"
}

# HTTP health check
resource "google_compute_http_health_check" "reddit-app-health-check" {
  name               = "reddit-app-health-check"
  check_interval_sec = 5
  port               = "${var.app_port}"
  request_path       = "/"
  timeout_sec        = 5
}

# Backend service
resource "google_compute_backend_service" "reddit-app-backend-service" {
  name        = "reddit-app-backend-service"
  port_name   = "${local.app_port_name}"
  protocol    = "HTTP"
  timeout_sec = 10
  enable_cdn  = false

  backend {
    group = "${google_compute_instance_group.reddit-app-group.self_link}"
  }

  health_checks = ["${google_compute_http_health_check.reddit-app-health-check.self_link}"]
}

# URL mapping
# Compute Engine HTTP(S) Load Balancing allows you to direct traffic to different instances based on the incoming URL.
resource "google_compute_url_map" "reddit-app-url-map" {
  name = "reddit-app-url-map"

  default_service = "${google_compute_backend_service.reddit-app-backend-service.self_link}"
}

# Resource proxy
# Route incoming request to URL map
resource "google_compute_target_http_proxy" "reddit-app-resource-proxy" {
  name    = "reddit-app-resource-proxy"
  url_map = "${google_compute_url_map.reddit-app-url-map.self_link}"
}

# Forwarding rule
resource "google_compute_global_forwarding_rule" "reddit-app-forwarding-rule" {
  name       = "reddit-app-forwarding-rule"
  target     = "${google_compute_target_http_proxy.reddit-app-resource-proxy.self_link}"
  port_range = 80
}
