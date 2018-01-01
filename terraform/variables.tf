variable "project" {
  description = "Project ID"
}

variable "region" {
  default     = "europe-west1"
  description = "Region"
}

variable "storage_bucket_list" {
  default     = ["bucket-test-2", "bucket-test-1"]
  description = "List of GCS buckets"
}
