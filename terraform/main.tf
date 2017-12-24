# Google provider settings
provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
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
resource "google_compute_instance" "app" {
  name         = "reddit-app"
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
