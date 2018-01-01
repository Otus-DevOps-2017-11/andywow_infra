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
  source_ranges = "${var.ssh_source_ranges}"
}

module "projectsshkeys" {
  source            = "../modules/projectsshkeys"
  users_public_keys = "${var.users_public_keys}"
}

module "db" {
  source           = "../modules/db"
  db_port          = "${var.db_port}"
  disk_image_db    = "${var.disk_image_db}"
  private_key_path = "${var.private_key_path}"
  public_key_path  = "${var.public_key_path}"
  zone             = "${var.zone}"
}

module "app" {
  source           = "../modules/app"
  app_port         = "${var.app_port}"
  db_url           = "${module.db.db_internal_ip[0]}:${var.db_port}"
  disk_image_app   = "${var.disk_image_app}"
  instance_count   = "${var.instance_count_app}"
  private_key_path = "${var.private_key_path}"
  public_key_path  = "${var.public_key_path}"
  use_loadbalancer = "${var.create_loadbalancer}"
  zone             = "${var.zone}"
}

module "load_balancer" {
  source              = "../modules/loadbalancer"
  app_port            = "${var.app_port}"
  create_loadbalancer = "${var.create_loadbalancer}"
  instance_list       = "${module.app.instance_list}"
  zone                = "${var.zone}"
}
