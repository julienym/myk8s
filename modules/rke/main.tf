resource "rke_cluster" "rancher" {
  
  cluster_name = var.name
  
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
  # services {
  #   kube_api {
  #     extra_args = {  
  #       external-hostname = "api.k8s.locacloud.com"
  #     }
  #   }
  # }

  authentication {
    sans = [ "api.k8s.locacloud.com" ]
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

resource "local_file" "rancher_kubeconfig" {
    content  = replace(rke_cluster.rancher.kube_config_yaml, "/https:.*:6443/", "https://api.k8s.locacloud.com:6443") 
    filename = var.kubeconfig_path
}
