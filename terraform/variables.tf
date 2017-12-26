variable "app_port" {
  default     = "9292"
  description = "Application port"
}

variable "disk_image" {
  description = "Disk image"
}

variable "instance_count" {
  default     = 2
  description = "reddit-app instance count"
}

variable "private_key_path" {
  description = "Path to the private key used for ssh access"
}

variable "project" {
  description = "Project ID"
}

variable "provider_google_zone" {
  default     = "europe-west1-c"
  description = "zone name"
}

variable "public_key_path" {
  description = "Path to the public key used for ssh access"
}

variable "region" {
  default     = "europe-west1"
  description = "Region"
}

variable "users_public_keys" {
  type = "map"

  default = {
    "appuser1" = "~/.ssh/appuser1.pub"
    "appuser2" = "~/.ssh/appuser2.pub"
  }

  description = "user public keys"
}

variable "zone" {
  default     = "europe-west1-c"
  description = "Zone"
}
