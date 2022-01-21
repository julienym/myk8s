terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
    }
    rke = {
      source = "rancher/rke"
    }
  }
  required_version = ">= 0.13"
}
