
rke_name = "dev"
domain_name = "dev"
api_domain = "api.dev.locacloud.com"

nodes = {
  masters = {
    count = 1
    cores = 2
    ram_mb = 4069
    bridge = "vmbr2"
    storage = "SSD1"
    clone = "ubuntu18-template"
    name_prefix = "dev-master"
    macaddr = [
      "5A:31:FF:D6:47:91"
    ]
    roles = [
      "controlplane",
      "etcd"
    ]
  }
  workers = {
    count = 1
    cores = 4
    ram_mb = 8192
    bridge = "vmbr2"
    storage = "SSD1"
    clone = "ubuntu18-template"
    name_prefix = "dev-worker"
    macaddr = [
      "02:C3:B5:CA:2D:00",
      "02:C5:43:80:AF:1B"
    ]
    data_disk = [
      {
        mount = "/mnt/longhorn"
        storage = "SSD2"
        cache = "unsafe"
        size = "50G"
      }
    ]
    roles = [
      "worker"
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
