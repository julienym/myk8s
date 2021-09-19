resource "rke_cluster" "rancher" {
  
  dynamic "nodes" {
    for_each = var.nodes
    
    content {  
      address = "${nodes.value}.loca"
      user    = "ubuntu"
      role    = ["controlplane", "worker", "etcd"]
      ssh_key = file("~/.ssh/id_rsa")
    }
  }
  upgrade_strategy {
      drain = true
      max_unavailable_worker = "20%"
  }
}