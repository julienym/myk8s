
rke_name = "dev"
domain_name = "dev"

nodes = {
  masters = {
    count = 1
    cores = 2
    ram_mb = 4069
    bridge = "vmbr2"
    storage = "SSD1"
    clone = "ubuntu18-template"
    name_prefix = "k8s-dev-master"
    macaddr = [
      "5A:31:FF:D6:47:91"
    ]
  }
  workers = {
    count = 1
    cores = 4
    ram_mb = 8192
    bridge = "vmbr2"
    storage = "SSD1"
    clone = "ubuntu18-template"
    name_prefix = "k8s-dev-worker"
    macaddr = [
      "02:C3:B5:CA:2D:00"
    ]
  }
}

#Override the default variable instances/myk8s/variables.tf
bastion = {
  host = "bastion.pmx2.locacloud.com"
  user = "ubuntu"
  ssh_private_key = "~/.ssh/z600"
}

proxmox = {
    node_name = "pmx2"
    insecure = true
    use_bastion = true
    ssh_private_key = "~/.ssh/z600"
}
