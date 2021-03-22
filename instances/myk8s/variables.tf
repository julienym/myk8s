variable "proxmox_secrets" {
  type = object({
    url = string
    user = string
    pass = string
    insecure = bool
    debug = bool
  })
  description = "Proxmox secrets map"
  default = {
    url = ""
    user = ""
    pass = ""
    insecure = false
    debug = false
  }
  sensitive = true
}

# variable "vm_secrets" {
#   type = object({
#     private_key_path = string
#     public_key_path = list(string)

#   })
# }

# variable "proxmox_url" {
#   type = string
#   description = "Proxmox URL"
#   sensitive = true
# }

# variable "proxmox_user" {
#   type = string
#   description = "Proxmox username"
#   sensitive = true
# }

# variable "proxmox_pass" {
#   type = string
#   description = "Proxmox password"
#   sensitive = true
# }

# variable "proxmox_insecure" {
#     type = bool
#     description = "Is Proxmox TLS valid?"
#     default = false
# }