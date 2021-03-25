nodes = {
  masters = {
    count = 3
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

