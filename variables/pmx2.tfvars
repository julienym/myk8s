proxmox_vm = {
  name_prefix = "testVM"
  target_node = "pmx2"
  bridge = "vmbr1"
  clone = "bionic"
  disk_gb = 85 #Must be => clone
  ram_mb = 1024
  cores = 1
  storage = "SSD1"
  onboot = false
  cores = 1
}

vmCount = 3
