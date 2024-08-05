resource "kubernetes_manifest" "secret_provider_class" {
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"

    metadata = {
      name      = "${var.application_name}-${var.environment_name}-secret-provider-class"
      namespace = var.k8s_namespace
    }

    spec = {
      provider = "aws"
      parameters = {
        objects = yamlencode([
          {
            objectName         = "connection-string"
            objectType         = "secretsmanager"
            objectVersionLabel = "AWSCURRENT"
          }
        ])
      }
      secretObjects = [
        {
          data = [
            {
              key        = "connection-string"
              objectName = "connection-string"
            }
          ]
          secretName = "connection-string"
          type       = "Opaque"
        }
      ]
    }
  }
}

