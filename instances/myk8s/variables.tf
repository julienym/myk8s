variable "proxmox_secrets" {
  type = object({
    url = string
    user = string
    pass = string
    insecure = bool
    debug = bool
    ssh_host = string
    ssh_user = string
    ssh_port = number
    ssh_bastion = string
  })
  description = "Proxmox secrets map"
  default = {
    url = ""
    user = ""
    pass = ""
    insecure = false
    debug = false
    ssh_host = ""
    ssh_user = ""
    ssh_port = 22
    ssh_bastion = ""
  }
}

variable "nodes" {
  description = "Flexible user variable for nodes"
}

variable "nodes_default" {
  type = object({
    target_node = string
    bridge = string
    clone = string
    disk_gb = number
    ram_mb = number
    storage = string
    onboot = bool
    cores = number
  }) 
  default = {
    target_node = "pmx2"
    bridge = "vmbr1"
    clone = "bionic"
    disk_gb = 85 #Must be => clone
    ram_mb = 2048
    storage = "SSD1"
    onboot = false
    cores = 2
  }
  description = "Map de valeurs par défaut pour les nodes"
}
