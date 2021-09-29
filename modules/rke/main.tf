resource "rke_cluster" "rancher" {
  
  dynamic "nodes" {
    for_each = var.nodes
    
    content {  
      address = "${nonsensitive(nodes.value)}.loca"
      node_name = "${nonsensitive(nodes.value)}.loca"
      user    = "ubuntu"
      role    = ["controlplane", "worker", "etcd"]
      ssh_key = file("/home/julien/.ssh/z600")
    }
  }
  bastion_host {
    address = var.bastion.host
    user = var.bastion.user
    ssh_key = file(var.bastion.ssh_private_key)
  }
  upgrade_strategy {
      drain = true
      max_unavailable_worker = "20%"
  }
}