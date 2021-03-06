
rke_name = "rancher"
domain_name = "rancher"
api_domain = "api.rancher.locacloud.com"

rancher = {
  replicas = 1
}

nodes = {
  masters = {
    count = 1
    cores = 2
    ram_mb = 4069
    clone = "ubuntu18-template"
    name_prefix = "rancher-master"
    macaddr = [
      "0e:87:80:89:2b:29",
      "a6:ab:d8:f1:f5:0a",
      "fa:b4:d5:a4:a4:bf"
    ]
    roles = [
      "controlplane",
      "worker",
      "etcd"
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
