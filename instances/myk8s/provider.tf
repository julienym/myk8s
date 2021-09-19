provider "proxmox" {
    pm_api_url = var.proxmox_secrets.url
    pm_user = var.proxmox_secrets.user
    pm_password = var.proxmox_secrets.pass
    pm_tls_insecure = var.proxmox_secrets.insecure
    pm_log_enable = var.proxmox_secrets.debug
    pm_log_file = var.proxmox_secrets.debug ? "terraform-plugin-proxmox.log" : ""
    pm_log_levels = var.proxmox_secrets.debug ? {
        _default = "info"
        _capturelog = ""
    } : {}
}

provider "rke" {
  debug = false
#   log_file = "<RKE_LOG_FILE>"
}