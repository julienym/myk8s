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
    
  target_node = local.proxmox.node_name
  snippet = "${path.module}/templates/rke-master.yml"
  bridge = local.masters.bridge
  clone = local.masters.clone
  disk_gb = local.masters.disk_gb
  ram_mb = local.masters.ram_mb
  cores = local.masters.cores
  storage = local.masters.storage
  onboot = local.masters.onboot
  macaddr = local.masters.macaddr[count.index]
}

module "rke" {
  source = "../../modules/rke"

  nodes = [ for node in module.proxmox_node_masters.*.proxmox_nodes: node ]
  bastion = local.bastion
}


module "rancher" {
  source = "../../modules/rancher"

}