output "client_cert" {
  value = rke_cluster.this.client_cert 
} 

output "client_key" {
  value = rke_cluster.this.client_key 
}

output "ca_crt" {
  value = rke_cluster.this.ca_crt 
}


# output "kubeconfig" {
#   value = rke_cluster.this.kube_config_yaml
#   sensitive = true
# }

output "api_url" {
  value = rke_cluster.this.api_server_url
}