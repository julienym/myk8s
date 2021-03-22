resource "proxmox_vm_qemu" "vms" {
  name = "${var.proxmox_vm.name_prefix}-${var.countIndex}"

  #Provisionning settings
  # preprovision = true
  os_type = "cloud-init"
  target_node = var.proxmox_vm.target_node
  clone = var.proxmox_vm.clone
  full_clone = false

  #CPU settings
  cpu = "kvm64"
  cores = var.proxmox_vm.cores
  sockets = 1

  #RAM settings
  memory = var.proxmox_vm.ram_mb
  balloon = 1

  #Disk settings
  disk {
    type = "virtio"
    size = "${var.proxmox_vm.disk_gb}G"
    storage = var.proxmox_vm.storage
    cache = "unsafe"
    # ssd = true
  }

  #Network settings
  network {
    model = "virtio"
    bridge = var.proxmox_vm.bridge
  }

  #Cloud-init settings
  ciuser = "ubuntu"
  cicustom = "user=local:snippets/k8s-cloud-config.yml"
  ipconfig0 = "ip=dhcp"
  # sshkeys = file("/home/julien/.ssh/id_rsa.pub")
}

