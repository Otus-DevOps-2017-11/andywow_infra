output "app_external_ip" {
  value = "${module.app.app_external_ip}"
}

output "db_external_ip" {
  value = "${module.db.db_external_ip}"
}

output "load_balancer_ip" {
  value = "${module.load_balancer.load_balancer_ip}"
}
