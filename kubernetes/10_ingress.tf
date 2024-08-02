resource "helm_release" "ingress" {
  name = "ingress"
  repository = "https://chart.bitnami.com/bitnami"
  chart = "nginx-ingress-controller"

  create_namespace = true
  namespace = "ingress-nginx"

  set {
    name = "service.type"
    value = "LoadBalancer"
  }

  set { 
    name = "service.annotation"
    value = "service.beta.kubernetes.io/aws-load-balancer-type: nlb"
  }
}

resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name = "${var.application_name}-ingress"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }
  
  spec {
    rule {
      http { 
        path {
          path = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.web_app.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
  
  depends_on = [
    kubernetes_service.web_app,
    helm_release.ingress
  ]
}

