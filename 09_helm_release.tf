resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.3.10"

  namespace = "argocd"

  create_namespace = true

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "server.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }
}

resource "helm_release" "announcements-dev" {

  name = "announcements-dev"

  repository = "https://ucf.github.io/UCF-Announcements-Django/"
  chart = "./announcements"
  namespace = "announcements-dev"

  set {
    name = "protocolHttp"
    value = "true"
  }

}

resource "helm_release" "announcements-qa" {

  name = "announcements-qa"
  repository = "https://ucf.github.io/UCF-Announcements-Django/"
  chart = "./announcements"
  namespace = "announcements-qa"

  set {
    name = "protocolHttp"
    value = "true"
  }
}
