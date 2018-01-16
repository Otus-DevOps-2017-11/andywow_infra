# Google provider settings
provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

module "storage_bucket" {
  source  = "SweetOps/storage-bucket/google"
  version = "0.1.1"
  name    = "${var.storage_bucket_list}"
}

output "storage_bucket_url" {
  value = "${module.storage_bucket.url}"
}
