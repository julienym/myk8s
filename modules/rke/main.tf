resource "rke_cluster" "rancher" {
  
  cluster_name = var.name
  
  dynamic "nodes" {
    for_each = nonsensitive(var.nodes)
    
    content {  
      address = "${nodes.key}.${var.domain_name}"
      node_name = "${nodes.key}.${var.domain_name}"
      user    = "ubuntu"
      role    = nodes.value
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
    sans = [ var.api_domain ]
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
    content  = replace(rke_cluster.rancher.kube_config_yaml, "/https:.*:6443/", "https://${var.api_domain}:6443") 
    filename = var.kubeconfig_path
}
