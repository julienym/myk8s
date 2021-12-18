output "client_cert" {
  value = rke_cluster.rancher.client_cert 
} 

output "client_key" {
  value = rke_cluster.rancher.client_key 
}

output "ca_crt" {
  value = rke_cluster.rancher.ca_crt 
}


# output "kubeconfig" {
#   value = rke_cluster.rancher.kube_config_yaml
#   sensitive = true
# }

output "api_url" {
  value = rke_cluster.rancher.api_server_url
}