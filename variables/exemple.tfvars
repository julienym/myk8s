
rke_name = "rancher"
domain_name = "loca"

nodes = {
  masters = {
    count = 3
    cores = 2
    ram_mb = 4069
    clone = "ubuntu18-template"
    name_prefix = "k8s-master"
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
  #Minimum 1 node with worker role for nginx ingress controller
  workers = {
    count = 1
    cores = 4
    ram_mb = 8192
    clone = "ubuntu18-template"
    name_prefix = "k8s-worker"
    macaddr = [
      "26:f8:c6:70:3a:dd",
      "dd:35:b6:65:d1:1d",
      "29:69:d5:5a:4c:65"
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
