variable "app_port" {
  default     = "9292"
  description = "Application port"
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

variable "zone" {
  default     = "europe-west1-c"
  description = "Zone"
}
