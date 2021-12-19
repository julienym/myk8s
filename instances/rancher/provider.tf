provider "proxmox" {
    pm_api_url = local.proxmox_secrets.url
    pm_user = local.proxmox_secrets.user
    pm_password = local.proxmox_secrets.pass
    pm_tls_insecure = local.proxmox.insecure
    pm_log_enable = local.proxmox.debug
    pm_log_file = local.proxmox.debug ? "terraform-plugin-proxmox.log" : ""
    pm_log_levels = local.proxmox.debug ? {
        _default = "info"
        _capturelog = ""
    } : {}
}

provider "rke" {
  debug = false
#   log_file = "<RKE_LOG_FILE>"
}

provider "helm" {
  kubernetes {
    host     = "https://${var.api_domain}:6443"

    client_certificate     = module.rke.client_cert 
    client_key             = module.rke.client_key 
    cluster_ca_certificate = module.rke.ca_crt 
  }
}