locals {
  masters = merge(var.nodes_default, var.nodes.masters)
  workers = merge(var.nodes_default, var.nodes.workers)
}