# ip address
resource "google_compute_address" "app_ip" {
  #count = "${var.use_loadbalancer ? 0 : var.instance_count+1}"
  count = "${var.instance_count}"
  name  = "reddit-app-ip-${count.index+1}"
  address_type = "${var.use_loadbalancer ? "INTERNAL" : "EXTERNAL"}"
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

# Puma services temlate
data "template_file" "puma_service" {
  template = "${file("${path.module}/files/puma.service.tpl")}"

  vars {
    app_port = "${var.app_port}"
    db_url   = "${var.db_url}"
  }
}

# Reddit instance settings
resource "google_compute_instance" "app" {
  count        = "${var.instance_count}"
  name         = "reddit-app-${count.index+1}"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["reddit-app"]

  boot_disk {
    initialize_params {
      image = "${var.disk_image_app}"
    }
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  network_interface {
    network = "default"

    access_config = {
      nat_ip = "${var.use_loadbalancer ? "" :
        google_compute_address.app_ip.*.address[count.index]}"
    }
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
    script = "${path.module}/files/deploy.sh"
  }
}
