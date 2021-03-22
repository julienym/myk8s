variable "proxmox_vm" {
  type = object({
    name_prefix = string
    target_node = string
    bridge = string
    clone = string
    disk_gb = number
    ram_mb = number
    cores = number
    storage = string
    onboot = bool
    cores = number
  })
}
