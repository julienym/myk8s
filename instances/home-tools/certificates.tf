resource "tls_private_key" "ca_private" {
  algorithm = "RSA"
  rsa_bits = 2048
}

resource "tls_self_signed_cert" "ca_cert" {
  key_algorithm   = tls_private_key.ca_private.algorithm
  private_key_pem = tls_private_key.ca_private.private_key_pem

  subject {
    common_name  = "tools.home"
    organization = "LocaCloud"
  }
  dns_names = ["tools.home", "*.tools.home"]

  validity_period_hours = 87600 #10 years

  is_ca_certificate = true
  
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]
}

resource "kubernetes_manifest" "cluster_ca" {
  depends_on = [
    module.cert-manager
  ]
  manifest = {
    apiVersion = "v1"
    kind = "Secret"
    metadata = {
      name = "ca-key-pair"
      namespace = "cert-manager"
    }
    data = {
    #   "tls.crt" = base64encode(tls_self_signed_cert.ca_cert.cert_pem)
    #   "tls.key" = base64encode(tls_private_key.ca_private.private_key_pem)
      "tls.crt" = base64encode(file("${path.module}/pfsense.crt"))
      "tls.key" = base64encode(file("${path.module}/pfsense.key"))
    }
  }
}

resource "kubernetes_manifest" "cluster_issuer" {
  depends_on = [
    module.cert-manager,
    kubernetes_manifest.cluster_ca
  ]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name      = "tools-ca"
    }
    spec = {
      ca = {
        secretName = "ca-key-pair"
      }
    }
  }
}
