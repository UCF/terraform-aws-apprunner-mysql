resource "kubernetes_namespace" "announcements-dev" {
  metadata {
    name = "announcements-dev"
  }
}

resource "kubernetes_namespace" "announcements-qa" {
  metadata { 
    name = "announcements-qa"
  }
}

resource "kubernetes_namespace" "announcements-prod" {
  metadata { 
    name = "announcements-prod"
  }
}
