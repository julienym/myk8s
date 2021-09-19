terraform {
  required_providers {
    rke = {
      source = "rancher/rke"
      version = "~> 1.2"
    }
  }
  required_version = ">= 0.13"
}
