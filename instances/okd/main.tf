# resource "null_resource" "download_required_script" {
#   provisioner "file" {
#     source      = "${path.module}/scripts/download-req.sh"
#     destination = "/tmp/download-req.sh"
#   }

#   connection {
#     type     = "ssh"
#     user     = local.proxmox_secrets.ssh_user
#     private_key = file(local.proxmox.ssh_private_key)
#     host     = local.proxmox_secrets.ssh_host
#     port     = local.proxmox_secrets.ssh_port
#   }

#   triggers = {
#     filemd5 = filemd5("${path.module}/scripts/download-req.sh")
#   }
# }

resource "null_resource" "required_files" {
  # depends_on = [
  #   null_resource.download_required_script
  # ]
  for_each = toset(var.okd_required_files)

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/download-req.sh ${each.value} ${path.module}/ocpdownloads 200k"
  }
}

# resource "null_resource" "docker_pull" {
#   for_each = toset(var.docker_images)

#   provisioner "local-exec" {
#     command = "docker image pull ${each.value}"
#   }
# }

resource "null_resource" "openshift_install" {
  depends_on = [
    null_resource.required_files
  ]
  provisioner "local-exec" {
    command = <<-EOT
      mkdir -p ./install_dir
      cp -f ./install-config.yaml ./install_dir/install-config.yaml
      ./ocpdownloads/openshift-install create manifests --dir=./install_dir
      ./ocpdownloads/openshift-install create ignition-configs --dir=./install_dir       
    EOT 
  }

  triggers = {
    filemd5 = filemd5("${path.module}/install-config.yaml")
  }
}

# data "external" "ign_file_hack" {
#   depends_on = [
#     null_resource.openshift_install
#   ]
#   for_each = toset(["bootstrap", "master", "worker"])
#   program = ["${path.module}/jq_hack.sh", "${path.module}/install_dir/${each.value}.ign"]
# }

# # output "data" {
# #   value =  data.external.ign_file_hack
# # }

resource "local_file" "installer_bu" {
  depends_on = [
    null_resource.openshift_install
  ]
  for_each = toset(["bootstrap"]) #, "master", "worker"])

  content = templatefile("${path.module}/templates/installer_template.bu",
    {
      block_device = "/dev/vda",
      # ca_certificate = tostring(file("${path.module}/pfsense.crt")),
      ignition_config_file = "${each.value}.ign" #tostring(base64decode(data.external.ign_file_hack["${each.value}"].result["base64_encoded"]))
    }
  )
  filename = "${path.module}/install_dir/${each.key}.bu"
  
  # lifecycle {
  #   ignore_changes = [
  #     content
  #   ]
  # }
}

resource "null_resource" "bu_2_ign" {
  for_each = local_file.installer_bu

  provisioner "local-exec" {
    command = "docker run -i --rm -v $(pwd)/install_dir:/ign -w /ign quay.io/coreos/butane:release -s --files-dir . -p ${basename(each.value.filename)} > ${path.module}/install_dir/installer-${trimsuffix(basename(each.value.filename), ".bu")}.ign"
  }
}

resource "null_resource" "iso_prep" {
  depends_on = [
    null_resource.bu_2_ign
  ]
  for_each = local_file.installer_bu

  provisioner "local-exec" {
    command = <<-EOT
      docker run --rm -v $(pwd)/install_dir:/ign -v $(pwd)/ocpdownloads:/iso -w /iso quay.io/coreos/coreos-installer:v0.10.1 \
        iso ignition embed -f -i /ign/installer-${trimsuffix(basename(each.value.filename), ".bu")}.ign -o ${trimsuffix(basename(each.value.filename), ".bu")}.iso \
        fedora-coreos-34.20211031.3.0-live.x86_64.iso
      docker run --rm -v $(pwd)/ocpdownloads:/iso -w /iso quay.io/coreos/coreos-installer:v0.10.1 iso kargs modify \
        -a coreos.inst.install_dev=/dev/vda \
        -a coreos.inst.platform_id=qemu \
        ${trimsuffix(basename(each.value.filename), ".bu")}.iso
    EOT 
  }
  # -a coreos.live.rootfs_url=https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/35.20220116.3.0/x86_64/fedora-coreos-35.20220116.3.0-live-rootfs.x86_64.img \

  # triggers = {
  #   filemd5 = filemd5("${path.module}/install_dir/${each.value}")
  # }
}

#On destroy this file is not deleted on the host!
resource "null_resource" "upload_isos" {
  depends_on = [
    null_resource.iso_prep
  ]
  for_each = local_file.installer_bu

  provisioner "file" {
    source      = "${path.module}/ocpdownloads/${trimsuffix(basename(each.value.filename), ".bu")}.iso"
    destination = "/var/lib/vz/template/iso/${trimsuffix(basename(each.value.filename), ".bu")}.iso"
  }

  connection {
    type     = "ssh"
    user     = local.proxmox_secrets.ssh_user
    private_key = file(local.proxmox.ssh_private_key)
    host     = local.proxmox_secrets.ssh_host
    port     = local.proxmox_secrets.ssh_port
  }

  # triggers = {
  #   filemd5 = filemd5("${path.module}/install_dir/${each.value}")
  # }
}

module "okd_node_bootstrap" {
  depends_on = [
    null_resource.upload_isos
  ]
  source = "../../modules/proxmox"
  count = 1

  providers = {
    proxmox = proxmox
  }
  name = "okd-bootstrap"
  domain_name = var.domain_name
  
  target_node = local.proxmox.node_name
  # snippet = "${path.module}/templates/dev.yml"
  bridge = local.masters.bridge
  # clone = local.masters.clone
  iso = "local:iso/bootstrap.iso"
  agent = "0" #TO DO
  disk_gb = local.masters.disk_gb
  ram_mb = local.masters.ram_mb
  cores = local.masters.cores
  storage = local.masters.storage
  onboot = local.masters.onboot
  macaddr = "4E:A4:1B:51:42:34"
  bastion = local.bastion
  data_disk = local.masters.data_disk
}

# # module "proxmox_node_masters" {
# #   depends_on = [
# #     module.proxmox_node_bootstrap
# #   ]
# #   source = "../../modules/proxmox"
# #   count = local.masters.count

# #   providers = {
# #     proxmox = proxmox
# #   }
# #   name = "${local.masters.name_prefix}-${count.index}"
# #   domain_name = var.domain_name
  
# #   target_node = local.proxmox.node_name
# #   # snippet = "${path.module}/templates/dev.yml"
# #   bridge = local.masters.bridge
# #   # clone = local.masters.clone
# #   iso = "okd_master.iso"
# #   disk_gb = local.masters.disk_gb
# #   ram_mb = local.masters.ram_mb
# #   cores = local.masters.cores
# #   storage = local.masters.storage
# #   onboot = local.masters.onboot
# #   macaddr = local.masters.macaddr[count.index]
# #   # bastion = local.bastion
# #   data_disk = local.masters.data_disk
# # }

# # module "proxmox_node_workers" {
# #   depends_on = [
# #     module.proxmox_node_bootstrap
# #   ]
# #   source = "../../modules/proxmox"
# #   count = local.workers.count

# #   providers = {
# #     proxmox = proxmox
# #   }
# #   name = "${local.workers.name_prefix}-${count.index}"
# #   domain_name = var.domain_name
  
# #   target_node = local.proxmox.node_name
# #   snippet = "${path.module}/templates/dev-worker.yml"
# #   # snippet = "${path.module}/templates/dev.yml"
# #   bridge = local.workers.bridge
# #   # clone = local.workers.clone
# #   iso = "okd_worker.iso"
# #   disk_gb = local.workers.disk_gb
# #   ram_mb = local.workers.ram_mb
# #   cores = local.workers.cores
# #   storage = local.workers.storage
# #   onboot = local.workers.onboot
# #   macaddr = local.workers.macaddr[count.index]
# #   # bastion = local.bastion
# #   data_disk = local.workers.data_disk
# # }
