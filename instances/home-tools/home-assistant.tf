# module "home-assistant" {
#   depends_on = [
#     module.mqtt,
#   ]
#   source = "../../modules/helm"
#   name = "home-assistant"
#   namespace = "home-assistant"
#   chart      = "${path.module}/../../charts/hass"
#   values_file = "hass.conf.yaml"
# }
