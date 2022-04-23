module "eck-operator" {
  depends_on = [
    module.longhorn,
  ]
  source = "../../modules/helm"
  name = "eck"
  repository = "https://helm.elastic.co"
  namespace = "elastic-system"
  chart = "eck-operator"
  chart_version = "2.0.0"
  values = {
    "image.repository" = "harbor.tools.home/elastic/eck/eck-operator"
    "config.containerRegistry" = "harbor.tools.home/elastic"
  }
}

resource "kubectl_manifest" "eck_es" {
  depends_on = [
    module.eck-operator
  ]
  yaml_body = <<YAML
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: quickstart
  namespace: elastic-system
spec:
  version: 8.0.1
  nodeSets:
  - name: default
    count: 1
    config:
      node.store.allow_mmap: false
YAML
}




