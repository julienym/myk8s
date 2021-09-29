nodes = {
  masters = {
    count = 1
    clone = "ubuntu18-template"
    name_prefix = "k8s-master"
    macaddr = [
      "0e:87:80:89:2b:29",
      "a6:ab:d8:f1:f5:0a",
      "fa:b4:d5:a4:a4:bf"
    ]
  }
  workers = {
    count = 3
    name_prefix = "k8s-worker"
    ram_mb = 4096
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
