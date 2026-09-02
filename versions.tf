terraform {
  required_version = ">= 1.0"

  required_providers {
    port = {
      source  = "port-labs/port"
      version = "~> 2.0"
    }
  }
}
