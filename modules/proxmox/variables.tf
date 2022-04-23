# variable "cloudInitFilePath" {
#   type = string
# }

variable "snippet" {
  type = string
  default = ""
  description = "Snippet location"
}

variable "name" {
  type = string
}
variable "target_node" {
  type = string
}
variable "bridge" {
  type = string
}
variable "clone" {
  type = string
  default = null
  description = "VM Clone template name"
}
variable "iso" {
  type = string
  default = null
  description = "ISO file path on the hypervisor"
}
variable "disk_gb" {
  type = number
}
variable "ram_mb" {
  type = number
}
variable "cores" {
  type = number
}
variable "storage" {
  type = string
}
variable "onboot" {
  type = bool
  default = false
}
variable "macaddr" {
  type = string
  default = ""
}

variable "domain_name" {
  type = string
}
variable "bastion" {
  type = map(string)
  default = {
    host = ""
    user = ""
    port = ""
  }
}

variable "data_disk" {}

variable "agent" {
  type = string
  default = "1"
}

variable "provision_verification" {
  type = string
  default = "cloud-init status --wait > /dev/null"
}

variable "ssh_user" {
  type = string
  default = "ubuntu"
}