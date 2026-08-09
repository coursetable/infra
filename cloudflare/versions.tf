terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket = "coursetable-terraform-state"
    key    = "cloudflare/terraform.tfstate"
    region = "auto"

    endpoints = {
      s3 = "https://b30c1d958879fa568e6a0e7570abe0bb.r2.cloudflarestorage.com"
    }

    use_lockfile                = true
    use_path_style              = true
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

provider "cloudflare" {}
