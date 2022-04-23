locals {
  proxmox = merge(var.proxmox_default, var.proxmox)
  proxmox_secrets = merge(var.proxmox_secrets_default, var.proxmox_secrets)
  bastion = merge(var.bastion_default, var.bastion)
  bootstrap = merge(var.nodes_default, var.nodes.bootstrap)
  masters = merge(var.nodes_default, var.nodes.masters)
  workers = merge(var.nodes_default, var.nodes.workers)
}