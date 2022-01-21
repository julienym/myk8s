output "proxmox_nodes" {
  value = proxmox_vm_qemu.vms.name
  # value = proxmox_vm_qemu.vms
  sensitive   = true
}