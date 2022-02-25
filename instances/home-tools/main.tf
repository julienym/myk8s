data "template_file" "cloud_init_template" {
  for_each = fileset("${path.module}/templates/", "*")

  template  = file("${path.module}/templates/${each.value}")

  vars = {
    mount = "/mnt/longhorn"
  }
}

resource "null_resource" "cloud_init_config_files" {
  for_each = data.template_file.cloud_init_template

  provisioner "file" {
    content = each.value.rendered
    destination = "${local.proxmox.template_location}/${each.key}"

    connection {
      type     = "ssh"
      user     = local.proxmox_secrets.ssh_user
      private_key = file(local.proxmox.ssh_private_key)
      host     = local.proxmox_secrets.ssh_host
      port     = local.proxmox_secrets.ssh_port
      bastion_host = local.bastion.host != "" ? local.bastion.host : null
      bastion_user = local.bastion.host != "" ? local.bastion.user : null
      bastion_port = local.bastion.host != "" ? local.bastion.port : null
      bastion_private_key = local.bastion.host != "" ? file(local.bastion.ssh_private_key) : null
    }
  }

  triggers = {
    fileSHA = sha256(each.value.rendered)
  }
}

module "proxmox_node_masters" {
  depends_on = [
    null_resource.cloud_init_config_files
  ]
  source = "../../modules/proxmox"
  count = local.masters.count

  providers = {
    proxmox = proxmox
  }
  name = "${local.masters.name_prefix}-${count.index}"
  domain_name = var.domain_name
  
  target_node = local.proxmox.node_name
  agent = "0"
  snippet = "${path.module}/templates/rancher.yml"
  bridge = local.masters.bridge
  clone = local.masters.clone
  disk_gb = local.masters.disk_gb
  ram_mb = local.masters.ram_mb
  cores = local.masters.cores
  storage = local.masters.storage
  onboot = local.masters.onboot
  macaddr = local.masters.macaddr[count.index]
  bastion = local.bastion
  data_disk = local.masters.data_disk
}


module "proxmox_node_workers" {
  depends_on = [
    null_resource.cloud_init_config_files
  ]
  source = "../../modules/proxmox"
  count = local.workers.count

  providers = {
    proxmox = proxmox
  }
  name = "${local.workers.name_prefix}-${count.index}"
  domain_name = var.domain_name
  
  target_node = local.proxmox.node_name
  agent = "0"
  snippet = "${path.module}/templates/worker.yml"
  bridge = local.workers.bridge
  clone = local.workers.clone
  disk_gb = local.workers.disk_gb
  ram_mb = local.workers.ram_mb
  cores = local.workers.cores
  storage = local.workers.storage
  onboot = local.workers.onboot
  macaddr = local.workers.macaddr[count.index]
  bastion = local.bastion
  data_disk = local.workers.data_disk
}

module "rke" {
  source = "../../modules/rke"

  name = var.rke_name
  domain_name = var.domain_name
  api_domain = var.api_domain

  # nodes = { for node in module.proxmox_node_rancher.*.proxmox_nodes: node => local.masters.roles }
  nodes = local.nodeMap
  bastion = local.bastion
  kubeconfig_path = "/home/julien/.kube/clusters/${var.rke_name}"
}

# output "node" {
#   value = [ for node in module.proxmox_node_workers.*.proxmox_nodes: nonsensitive(node) ]
#     # { for node, values in module.proxmox_node_workers.*.proxmox_nodes: node => {
#     #     vmCode = nonsensitive(values) #.force_recreate_on_change_of,
#     #     roles = local.masters.roles }}
#   # sensitive = true
# }

module "cert-manager" {
  source = "../../modules/helm"
  name = "cert-manager"
  repository = "https://charts.jetstack.io"
  namespace = "cert-manager"
  chart = "cert-manager"
  chart_version = "v1.6.1"
  values = {
    installCRDs = true
  }
}

module "rancher" {
  depends_on = [
    module.cert-manager
  ]
  source = "../../modules/helm"
  name = "rancher"
  repository = "https://releases.rancher.com/server-charts/stable"
  namespace = "cattle-system"
  chart = "rancher"
  chart_version = "2.6.3"
  values = {
    hostname = "rancher.tools.home"
    "ingress.tls.source" = "rancher"
    bootstrapPassword = var.rancher_bootstrap
    "certmanager.version" = "1.6.1"
    replicas = var.rancher.replicas
  }
}

module "longhorn" {
  depends_on = [
    module.rancher
  ]
  source = "../../modules/helm"
  name = "longhorn"
  repository = "https://charts.longhorn.io"
  namespace = "longhorn-system"
  chart = "longhorn"
  chart_version = "1.2.3"
  values = {
    "defaultSettings.defaultDataPath" = "/mnt/longhorn"
    "defaultSettings.defaultReplicaCount" = 1
    "csi.attacherReplicaCount" = 1
    "csi.provisionerReplicaCount" = 1
    "csi.resizerReplicaCount" = 1
    "csi.snapshotterReplicaCount" = 1
  }
}

module "harbor" {
  depends_on = [
    module.longhorn,
    kubernetes_manifest.cluster_issuer
  ]
  source = "../../modules/helm"
  name = "harbor"
  repository = "https://helm.goharbor.io"
  namespace = "harbor"
  chart = "harbor"
  chart_version = "1.8.1"
  values = {
    "expose.tls.certSource" = "secret"
    "expose.tls.secret.secretName" = "harbor-cert"
    "expose.ingress.hosts.core" = "harbor.tools.home"
    "expose.ingress.hosts.notary" = "notary.tools.home"
    "expose.ingress.harbor.annotations.cert-manager\\.io/cluster-issuer" = "tools-ca"
    externalURL = "https://harbor.tools.home"
    "ipFamily.ipv6.enabled" = false
    "persistence.resourcePolicy" = ""
    "persistence.persistentVolumeClaim.registry.size" = "50Gi"
    harborAdminPassword = var.harbor_admin_password
    secretKey = var.harbor_storage_encryption
    # "registry.credentials.password"
    "chartmuseum.enabled" = false
    "trivy.enabled" = true
    "notary.enabled" = false
    "database.internal.password" = var.harbor_db_passwd
  }
}