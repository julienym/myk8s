resource "rke_cluster" "this" {
  
  cluster_name = var.name
  
  dynamic "nodes" {
    for_each = var.nodes
    
    content {  
      address = "${nodes.key}.${var.domain_name}"
      node_name = "${nodes.key}.${var.domain_name}"
      user    = "ubuntu"
      role    = nodes.value["roles"]
      labels = {
        vmId = nodes.value["vmCode"]
      }
      ssh_key = file("/home/julien/.ssh/z600")
    }
  }
  kubernetes_version = "v1.20.12-rancher1-1"
  # services {
  #   kube_api {
  #     extra_args = {  
  #       external-hostname = "api.k8s.locacloud.com"
  #     }
  #   }
  # }
  ingress {
    provider = "nginx"
    http_port = 80
    https_port = 443
    network_mode = "hostNetwork"
  }
  authentication {
    sans = [ var.api_domain ]
  }
  # bastion_host {
  #   address = var.bastion.host
  #   user = var.bastion.user
  #   ssh_key = file(var.bastion.ssh_private_key)
  # }
  upgrade_strategy {
      drain = false
  }
}

resource "local_file" "rancher_kubeconfig" {
    content  = replace(rke_cluster.this.kube_config_yaml, "/https:.*:6443/", "https://${var.api_domain}:6443") 
    filename = var.kubeconfig_path
}
