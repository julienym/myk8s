
rke_name = "home-tools"
domain_name = "tools.home"
api_domain = "rancher.tools.home"

rancher = {
  replicas = 1
}

nodes = {
  masters = {
    onboot = true
    count = 3
    cores = 2
    ram_mb = 4069
    bridge = "vmbr2"
    storage = "raid5"
    clone = "ubuntu-focal-template"
    name_prefix = "tools-master"
    macaddr = [
      "02:35:47:91:09:3E",
      "02:1F:E3:F4:D5:97",
      "02:20:82:0E:45:C1"
    ]
    roles = [
      "controlplane",
      "etcd"
    ]
    data_disk = []
  }
  workers = {
    onboot = true
    count = 3
    cores = 4
    ram_mb = 8192
    bridge = "vmbr2"
    storage = "raid5"
    clone = "ubuntu-focal-template"
    name_prefix = "tools-worker"
    macaddr = [
      "02:84:53:FD:BB:B2",
      "02:E0:D3:18:07:83",
      "02:13:9D:58:CA:7D"
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
