module "proxmox" {
  source = "../../modules/proxmox"
  count = 1

  providers = {
    proxmox = proxmox
  }

  proxmox_vm = var.proxmox_vm
  countIndex = count.index
}
