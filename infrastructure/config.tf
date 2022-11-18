terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.61.0"
    }
  }

  # Save state to remote S3 bucket
  backend "s3" {
    endpoint                    = var.backend_s3_endpoint
    bucket                      = var.s3_bucket_name
    region                      = var.zone
    key                         = var.s3_bucket_key
    access_key                  = var.s3_access_key
    secret_key                  = var.s3_secret_key
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  token     = var.IAM_token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}
