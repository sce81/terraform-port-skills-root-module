terraform {
  required_version = ">= 1.0"

  backend "s3" {
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    port = {
      source  = "port-labs/port-labs"
      version = "~> 2.4"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.5"
    }
  }
}

provider "port" {
}
