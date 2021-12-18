# output "proxmox_nodes" {
#   value = module.proxmox_masters.*.proxmox_nodes
#   sensitive   = true
# }

# output "templates" {
#   value = data.template_file.cloud_init_template
# }

# output "kubeconfig" {
#   value = nonsensitive(module.rke.kubeconfig)
# #   sensitive = true
# }

output "api_url" {
    value = module.rke.api_url
}