resource "null_resource" "cloud_init_config_files" {
  provisioner "file" {
    source      = "${path.root}/templates/k8s-cloud-config.yml"
    destination = "/var/lib/vz/snippets/k8s-cloud-config.yml"

    connection {
      type     = "ssh"
      user     = "ubuntu" #var.proxmox_secrets.user
      password = var.proxmox_secrets.pass
      private_key = file("/home/julien/.ssh/id_rsa")
      host     = var.proxmox_secrets.ssh_host
      port     = var.proxmox_secrets.ssh_port
      bastion_host = var.proxmox_secrets.ssh_bastion == "" ? "" : var.proxmox_secrets.ssh_bastion
      # bastion_user = "ubuntu"
      # bastion_private_key = file("/home/julien/.ssh/id_rsa")
    }
  }

  triggers = {
    fileSHA = sha256(file("${path.root}/templates/k8s-cloud-config.yml"))
  }
}

module "proxmox" {
  depends_on = [
    null_resource.cloud_init_config_files
  ]
  source = "../../modules/proxmox"
  count = 1

  providers = {
    proxmox = proxmox
  }
  cloudInitFilePath = "/var/lib/vz/snippets/k8s-cloud-config.yml"
  proxmox_vm = var.proxmox_vm
  countIndex = count.index
}
