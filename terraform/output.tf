output "app_external_ip" {
  value = "${google_compute_instance.reddit-app.*.network_interface.0.access_config.0.assigned_nat_ip}"
}

output "load_balancer_ip" {
  value = "${google_compute_global_forwarding_rule.reddit-app-forwarding-rule.ip_address}"
}
