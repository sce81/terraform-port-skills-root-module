terraform {
  required_version = ">= 1.0"

  backend "s3" {
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    port = {
      source  = "port-labs/port"
      version = "~> 2.25"
    }
  }
}

provider "port" {
}
