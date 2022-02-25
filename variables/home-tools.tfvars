
rke_name = "home-tools"
domain_name = "tools.home"
api_domain = "rancher.tools.home"

rancher = {
  replicas = 1
}

nodes = {
  masters = {
    count = 1
    cores = 2
    ram_mb = 4069
    bridge = "vmbr2"
    storage = "raid5"
    clone = "ubuntu-focal-template"
    name_prefix = "tools-master"
    macaddr = [
      "02:35:47:91:09:3E"
    ]
    roles = [
      "controlplane",
      "etcd",
      # "worker"
    ]
    data_disk = []
  }
  workers = {
    count = 1
    cores = 4
    ram_mb = 8192
    bridge = "vmbr2"
    storage = "raid5"
    clone = "ubuntu-focal-template"
    name_prefix = "tools-worker"
    macaddr = [
      "02:84:53:FD:BB:B2",
      # "02:C5:43:80:AF:1B"
    ]
    data_disk = [
      {
        mount = "/mnt/longhorn"
        storage = "raid5"
        cache = "unsafe"
        size = 200
      }
    ]
    roles = [
      "worker"
    ]
  }
}

#Override the default variable instances/myk8s/variables.tf
bastion = {
  # host = "bastion.pmx2.locacloud.com"
  # user = "ubuntu"
  ssh_private_key = "~/.ssh/z600"
  ssh_public_key = "~/.ssh/z600.pub"
}

proxmox = {
    node_name = "iris"
    insecure = true
    use_bastion = false
    ssh_private_key = "~/.ssh/z600"
}
