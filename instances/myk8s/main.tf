data "template_file" "cloud_init_template" {
  count = var.vmCount 
  template  = file("${path.module}/templates/k8s-cloud-config.yml")

  vars = {
    hostname = "${var.proxmox_vm.name_prefix}-${count.index}"
    domain = "loca"
  }
}

resource "null_resource" "cloud_init_config_files" {
  count = var.vmCount 

  provisioner "file" {
    content = data.template_file.cloud_init_template[count.index].rendered
    destination = "/var/lib/vz/snippets/k8s-cloud-config-${count.index}.yml"

    connection {
      type     = "ssh"
      user     = var.proxmox_secrets.ssh_user
      private_key = file("/home/julien/.ssh/z600")
      host     = var.proxmox_secrets.ssh_host
      port     = var.proxmox_secrets.ssh_port
      #bastion_host = var.proxmox_secrets.ssh_bastion == "" ? "" : var.proxmox_secrets.ssh_bastion
      # bastion_user = "ubuntu"
      # bastion_private_key = file("/home/julien/.ssh/id_rsa")
    }
  }

  #triggers = {
  #  fileSHA = sha256(file("${path.root}/templates/k8s-cloud-config.yml"))
  #}
}

module "proxmox" {
  depends_on = [
    null_resource.cloud_init_config_files
  ]
  source = "../../modules/proxmox"
  count = var.vmCount

  providers = {
    proxmox = proxmox
  }
  cloudInitFilePath = "k8s-cloud-config-${count.index}.yml"
  proxmox_vm = var.proxmox_vm
  countIndex = count.index
}
