variable db_port {
  default     = 27017
  description = "Database port"
}

variable "disk_image_db" {
  default     = "reddit-db-base"
  description = "Disk image of database"
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
