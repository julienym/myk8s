data "template_file" "cloud_init_template" {
  template  = file("${path.module}/templates/master.yml")

  vars = {
    domain = "k8s.loca"
  }
}

resource "null_resource" "cloud_init_config_files" {
  provisioner "file" {
    content = data.template_file.cloud_init_template.rendered
    destination = "/var/lib/vz/snippets/k8s-master.yml"

    connection {
      type     = "ssh"
      user     = var.proxmox_secrets.ssh_user
      private_key = file("/home/julien/.ssh/z600")
      host     = var.proxmox_secrets.ssh_host
      port     = var.proxmox_secrets.ssh_port
    }
  }

  triggers = {
    fileSHA = sha256(file("${path.root}/templates/master.yml"))
  }
}

module "proxmox_masters" {
  depends_on = [
    null_resource.cloud_init_config_files
  ]
  source = "../../modules/proxmox"
  count = local.masters.count

  providers = {
    proxmox = proxmox
  }
  cloudInitFilePath = "k8s-master.yml"
  name = "${local.masters.name_prefix}-${count.index}"
  target_node = local.masters.target_node
  bridge = local.masters.bridge
  clone = local.masters.clone
  disk_gb = local.masters.disk_gb
  ram_mb = local.masters.ram_mb
  cores = local.masters.cores
  storage = local.masters.storage
  onboot = local.masters.onboot
  macaddr = local.masters.macaddr[count.index]
}
