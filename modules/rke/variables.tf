variable "nodes" {
  # type = string
}

variable "bastion" {}

variable "kubeconfig_path" {
  type = string
}

variable "name" {
  type = string
}

variable "domain_name" {
  type = string
}


variable "api_domain" {
  type = string
}

# variable "bridge" {
#   type = string
# }
# variable "clone" {
#   type = string
# }
# variable "disk_gb" {
#   type = number
# }
# variable "ram_mb" {
#   type = number
# }
# variable "cores" {
#   type = number
# }
# variable "storage" {
#   type = string
# }
# variable "onboot" {
#   type = bool
# }
# variable "macaddr" {
#   type = string
# }