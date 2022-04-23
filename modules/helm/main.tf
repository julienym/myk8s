resource "helm_release" "this" {
  name       = var.name
  repository = var.repository
  chart      = var.chart
  version    = var.chart_version
  create_namespace = true
  namespace = var.namespace
  
  values = try([file(var.values_file)], null)

  dynamic "set" {
    for_each = var.values

    content {
      name = set.key
      value = set.value
    }
  }
}