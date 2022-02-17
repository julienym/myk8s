terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.9.5"
    }
    rke = {
      source = "rancher/rke"
    }
  }
  required_version = ">= 0.13"
}
