variable "disk_image" {
  description = "Disk image"
}

variable "project" {
  description = "Project ID"
}

variable "public_key_path" {
  description = "Path to the public key used for ssh access"
}

variable "region" {
  default     = "europe-west1"
  description = "Region"
}
