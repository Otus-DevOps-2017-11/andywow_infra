variable "app_port" {
  default     = "9292"
  description = "application port"
}

variable "create_loadbalancer" {
  default     = false
  description = "create load balancer"
}

variable "instance_list" {
  type        = "list"
  description = "instance list"
}

variable "zone" {
  default     = "europe-west1-c"
  description = "Zone"
}
