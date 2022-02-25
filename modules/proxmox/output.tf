output "proxmox_nodes" {
  value = proxmox_vm_qemu.vms.name
  # value = proxmox_vm_qemu.vms
  sensitive   = true
}

output "proxmox_changeId" {
  value = proxmox_vm_qemu.vms.force_recreate_on_change_of
}