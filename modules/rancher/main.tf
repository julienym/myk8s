resource "helm_release" "rancher" {
  name       = "rancher"
  repository = "https://releases.rancher.com/server-charts/stable"
  chart      = "rancher"
  version    = "2.5.9"
  create_namespace = true

  values = [
    "${file("${path.module}/rancher-values.yaml")}"
  ]

  set {
    name  = "replicas"
    value = "1"
  }
}