data "template_file" "cloud_init_template" {
  for_each = fileset("${path.module}/templates/", "*")

  template  = file("${path.module}/templates/${each.value}")

  # vars = {
  #   domain = "k8s.loca"
  # }
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
      bastion_host = local.bastion.host != "" ? local.bastion.host : ""
      bastion_user = local.bastion.host != "" ? local.bastion.user : ""
      bastion_port = local.bastion.host != "" ? local.bastion.port : ""
      bastion_private_key = local.bastion.host != "" ? file(local.bastion.ssh_private_key) : ""
    }
  }

  triggers = {
    fileSHA = sha256(each.value.rendered)
  }
}

module "proxmox_node_rancher" {
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
}

module "rke" {
  source = "../../modules/rke"

  name = var.rke_name
  domain_name = var.domain_name
  api_domain = var.api_domain

  nodes = { for node in module.proxmox_node_rancher.*.proxmox_nodes: node => local.masters.roles }
  # nodes = merge(
  #   { for node in module.proxmox_node_masters.*.proxmox_nodes: node => local.masters.roles },
  #   { for node in module.proxmox_node_workers.*.proxmox_nodes: node => local.workers.roles }
  # )
  bastion = local.bastion
  kubeconfig_path = "/home/julien/.kube/clusters/${var.rke_name}"
}

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
  chart_version = "2.6.2"
  values = {
    hostname = "rancher.locacloud.com"
    "ingress.tls.source" = "letsEncrypt"
    bootstrapPassword = var.rancher_bootstrap
    "certmanager.version" = "1.6.1"
    replicas = var.rancher.replicas
  }
}