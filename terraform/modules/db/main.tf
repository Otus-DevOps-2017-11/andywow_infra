# Firewall settings
resource "google_compute_firewall" "firewall_mongo" {
  name    = "allow-mongo-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["${var.db_port}"]
  }

  # tag - from connection
  source_tags = ["reddit-app"]

  # tag - to connection
  target_tags = ["reddit-db"]
}

# DB instance settings
resource "google_compute_instance" "db" {
  name         = "reddit-db"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["reddit-db"]

  boot_disk {
    initialize_params {
      image = "${var.disk_image_db}"
    }
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  network_interface {
    network = "default"

    access_config = {}
  }

  connection {
    type        = "ssh"
    user        = "appuser"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf",
      "sudo sed -i 's/27017/${var.db_port}/' /etc/mongod.conf",
      "sudo systemctl restart mongod",
    ]
  }
}
