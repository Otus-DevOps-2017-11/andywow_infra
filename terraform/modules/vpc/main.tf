# firewall rule SSH
resource "google_compute_firewall" "firewall_ssh" {
  name    = "default-allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  description   = "allow ssh connection"
  source_ranges = "${var.source_ranges}"
}
