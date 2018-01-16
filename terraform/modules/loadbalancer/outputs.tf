output "load_balancer_ip" {
  value = "${google_compute_global_forwarding_rule.app-forwarding-rule.*.ip_address}"
}
