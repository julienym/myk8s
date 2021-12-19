resource "proxmox_vm_qemu" "vms" {
  name = var.name

  #Provisionning settings
  # preprovision = true
  os_type = "cloud-init"
  target_node = var.target_node
  clone = var.clone
  full_clone = false
  #qemu_os = "other"

  #CPU settings
  cpu = "kvm64"
  cores = var.cores
  sockets = 1

  #RAM settings
  memory = var.ram_mb
  balloon = 0

  #Disk settings
  disk {
    type = "virtio"
    size = "${var.disk_gb}G"
    storage = var.storage
    cache = "unsafe"
    #file = ""
    #format = "raw"
    #slot = 0
    #storage_type = "lvmthin"
    #volume = ""
  }
 bootdisk = "virtio0"
 boot = "c"
 agent = 1
 onboot = false
 define_connection_info = true
 force_create = false
#  preprovision = false
 # scsihw = "lsi"

  #Network settings
  network {
    model = "virtio"
    bridge = var.bridge
    macaddr = var.macaddr == "" ? "" : var.macaddr 
  #  queues = 0
  #  rate = 0
  }
  #searchdomain = "pmx2"
  
  #Cloud-init settings
  cicustom = "user=local:snippets/${reverse(split("/", var.snippet))[0]}"
  force_recreate_on_change_of = sha256(file("${var.snippet}"))
  ipconfig0 = "ip=dhcp"
  ciuser = "ubuntu"
  # sshkeys = file("/home/julien/.ssh/id_rsa.pub")
  #nameserver = "172.16.0.1"

  lifecycle {
    ignore_changes = [
      #network[0].macaddr,
      #network[0].queues,
      #network[0].rate,
      #disk[0].file,
      #disk[0].format,
      #disk[0].slot,
      #disk[0].storage_type,
      #disk[0].volume
      #searchdomain,
    ]
  }


  provisioner "remote-exec" {
    inline = [ 
      "cloud-init status --wait > /dev/null"
    ]
  }

  connection {
    type     = "ssh"
    user     = "ubuntu" #Variable
    private_key = file(var.bastion.ssh_private_key) #Temp
    host     = "${var.name}.${var.domain_name}"
    port     = 22
    bastion_host = var.bastion.host != "" ? var.bastion.host : ""
    bastion_user = var.bastion.host != "" ? var.bastion.user : ""
    bastion_port = var.bastion.host != "" ? var.bastion.port : ""
    bastion_private_key = var.bastion.host != "" ? file(var.bastion.ssh_private_key) : ""
  }
}
