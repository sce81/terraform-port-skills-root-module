terraform {
  required_version = ">= 1.0"

  backend "local" {
    path = "terraform.tfstate"
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
