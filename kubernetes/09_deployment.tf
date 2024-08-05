data "aws_caller_identity" "current" {}

resource "kubernetes_deployment" "web_app" {

  metadata {
    name      = "${var.application_name}-${var.environment_name}"
    namespace = var.namespace
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "${var.application_name}-${var.environment_name}"
      }
    }

    template {
      metadata {
        labels = {
          app = "${var.application_name}-${var.environment_name}"

        }
      }
      spec {
        service_account_name = kubernetes_service_account.workload_identity.metadata[0].name
        container {
          image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.primary_region}.amazonaws.com/${var.web_app_image.name}:${var.web_app_image.version}"
          name  = var.application_name
          port {
            containerPort = 8000
          }
          env_from {
            config_map_ref {
              name = kubernetes_config_map.web_app.metadata[0].name
            }
          }
        }
      }
    }
  }

  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
  }
}

resource "kubernetes_service" "web_app" {
  metadata {
    name      = "${var.application_name}-service"
    namespace = var.namespace
  }

  spec {
    type = "ClusterIP"
    port {
      port        = 80
      target_port = 8000
    }

    selector = {
      app = var.application_name
    }
  }
}

resource "kubernetes_config_map" "web_app" {
  metadata {
    name      = "${var.application_name}-config"
    namespace = var.namespace
  }

  data = {
    BackendEndpoint = ""
  }
}

