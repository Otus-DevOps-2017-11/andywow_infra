variable "app_port" {
  default     = "9292"
  description = "Application port"
}

variable "db_host" {
  default     = "127.0.0.1"
  description = "Database host"
}

variable "db_port" {
  default     = "27017"
  description = "Database port"
}

variable "disk_image_app" {
  default     = "reddit-app-base"
  description = "Disk image of application"
}

variable "instance_count" {
  default     = 1
  description = "reddit-app instance count"
}

variable "private_key_path" {
  description = "Path to the private key used for ssh access"
}

variable "public_key_path" {
  description = "Path to the public key used for ssh access"
}

variable "use_loadbalancer" {
  default = "false"
  description = "Use load balancer instead of static extenal ip"
}

variable "zone" {
  default     = "europe-west1-c"
  description = "Zone"
}
