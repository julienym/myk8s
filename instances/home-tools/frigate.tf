resource "tls_private_key" "mqtt" {
  algorithm = "RSA"
  rsa_bits = 2048
}

resource "tls_cert_request" "mqtt" {
  key_algorithm   = tls_private_key.mqtt.algorithm
  private_key_pem = tls_private_key.mqtt.private_key_pem

  subject {
    common_name  = "mqtt"
    organization = "LocaCloud"
  }
}

resource "tls_locally_signed_cert" "mqtt" {
  cert_request_pem   = tls_cert_request.mqtt.cert_request_pem
  ca_key_algorithm   = tls_private_key.ca_private.algorithm
  ca_private_key_pem = tls_private_key.ca_private.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca_cert.cert_pem

  validity_period_hours = 87600 #10 years

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

module "mqtt" {
  depends_on = [
    module.longhorn,
    module.harbor
  ]
  source = "../../modules/helm"
  name = "mqtt"
  namespace = "frigate"
  chart      = "${path.module}/../../charts/mosquitto"
  values = {
    "image.repository" = "harbor.tools.home/docker/library/eclipse-mosquitto"
    "image.tag" = "2.0.14"
    "persistence.storageClass" = "longhorn"
    "certs.ca.crt" = tls_self_signed_cert.ca_cert.cert_pem
    "certs.server.crt" = tls_locally_signed_cert.mqtt.cert_pem
    "certs.server.key" = tls_private_key.mqtt.private_key_pem
  }
}

module "frigate" {
  depends_on = [
    module.mqtt,
  ]
  source = "../../modules/helm"
  name = "frigate"
  repository = "https://blakeblackshear.github.io/blakeshome-charts/"
  namespace = "frigate"
  chart = "frigate"
  chart_version = "6.3.0"
  values = {
    "config" = templatefile("${path.module}/mqtt_config.yml",
      {
        icams = {
          west1 = "icam-west1.home",
          # east1 = "icam-east1.home",
          # west2 = "icam-west2.home",
          # east2 = "icam-east2.home"
        }
      }
    )
    "image.repository" = "harbor.tools.home/docker/blakeblackshear/frigate"
    "image.tag" = "0.10.1-amd64"
    "ingress.annotations.cert-manager\\.io/cluster-issuer" = "tools-ca"
    "ingress.enabled" = true
    "ingress.hosts[0].host" = "frigate.tools.home"
    "ingress.hosts[0].paths[0]" = "/"
    "ingress.tls[0].hosts[0]" = "frigate.tools.home"
    "ingress.tls[0].secretName" = "frigate-https"
    "persistence.data.enabled" = true
    "persistence.data.skipuninstall" = false #Temp.
  }
}