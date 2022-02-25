variable "proxmox" {}
variable "proxmox_default" {
  type = object({
    insecure = bool
    debug = bool
    use_bastion = bool
    template_location = string
    node_name = string
  })
  description = "Proxmox map"
  default = {
    insecure = false
    debug = false
    use_bastion = false
    template_location = "/var/lib/vz/snippets"
    node_name = "pmx"
  }
}

variable "proxmox_secrets" {}
variable "proxmox_secrets_default" {
  type = object({
    url = string
    user = string
    pass = string
    ssh_host = string
    ssh_user = string
    ssh_port = number
  })
  description = "Proxmox secrets map"
  default = {
    url = ""
    user = ""
    pass = ""
    ssh_host = ""
    ssh_user = ""
    ssh_port = 22
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
    macaddr = list(string)
    roles = list(string)
  }) 
  default = {
    target_node = "pmx2"
    bridge = "vmbr1"
    clone = "bionic"
    disk_gb = 85 #Must be >= clone
    ram_mb = 2048
    storage = "SSD1"
    onboot = false
    cores = 2
    macaddr = [""]
    roles = ["worker"]
  }
  description = "Map de valeurs par défaut pour les nodes"
}

variable "bastion" {}
variable "bastion_default" {
  type = object({
    ssh_private_key = string
    ssh_public_key = string
    host = string
    user = string
    port = number
  }) 
  default = {
    ssh_private_key = "~/.ssh/id_rsa"
    ssh_public_key = "~/.ssh/id_rsa.pub"
    host = ""
    user = ""
    port = 22
  }
  description = "Default values for using a ssh bastion"
}

variable "rke_name" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "api_domain" {
  type = string
}


variable "rancher" {}

variable "rancher_bootstrap" {}

variable "harbor_admin_password" {}

variable "harbor_storage_encryption" {}

variable "harbor_db_passwd" {}