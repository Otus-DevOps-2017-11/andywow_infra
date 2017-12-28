locals {
  module_path = "../modules"
}

# backend
terraform {
  backend "gcs" {}
}

# Google provider settings
provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

module "vpc" {
  source        = "../modules/vpc"
  source_ranges = ["0.0.0.0/0"]
}

module "projectsshkeys" {
  source            = "../modules/projectsshkeys"
  users_public_keys = "${var.users_public_keys}"
}

module "db" {
  source          = "../modules/db"
  disk_image_db   = "${var.disk_image_db}"
  public_key_path = "${var.public_key_path}"
  zone            = "${var.zone}"
}

module "app" {
  source           = "../modules/app"
  app_port         = "${var.app_port}"
  disk_image_app   = "${var.disk_image_app}"
  private_key_path = "${var.private_key_path}"
  public_key_path  = "${var.public_key_path}"
  zone             = "${var.zone}"
}
