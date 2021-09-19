output "nodes" {
  value = [ for node in proxmox_vm_qemu.vms: node.name ]
} 