variable "disk_image" {
  description = "Disk image"
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

variable "zone" {
  default     = "europe-west1-c"
  description = "Zone"
}
