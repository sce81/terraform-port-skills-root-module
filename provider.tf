terraform {
  required_providers {
    port = {
      source  = "port-labs/port"
      version = "~> 2.25"
    }
  }
}

provider "port" {
}
