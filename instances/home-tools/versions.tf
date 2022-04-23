terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
    }
    rke = {
      source = "rancher/rke"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
  required_version = ">= 0.13"
}
