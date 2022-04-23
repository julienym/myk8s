locals {
  proxmox = merge(var.proxmox_default, var.proxmox)
  proxmox_secrets = merge(var.proxmox_secrets_default, var.proxmox_secrets)
  bastion = merge(var.bastion_default, var.bastion)
  masters = merge(var.nodes_default, var.nodes.masters)
  workers = merge(var.nodes_default, var.nodes.workers)
  nodeMap = merge(
    { for index, node in module.proxmox_node_masters.*.proxmox_nodes: nonsensitive(node) => {
        vmCode = substr(sha1(module.proxmox_node_masters[tonumber(index)].proxmox_changeId), 0, 62), #["force_recreate_on_change_of"],
        roles = local.masters.roles }},
    { for index, node in module.proxmox_node_workers.*.proxmox_nodes: nonsensitive(node) => {
        vmCode = substr(sha1(module.proxmox_node_workers[tonumber(index)].proxmox_changeId), 0, 62), #["force_recreate_on_change_of"],
        roles = local.workers.roles }}
  )
}