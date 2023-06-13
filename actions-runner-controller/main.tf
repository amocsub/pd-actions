resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  chart            = "cert-manager"
  repository       = "https://charts.jetstack.io"
  namespace        = "cert-manager"
  version          = "1.12.1"
  create_namespace = true
  cleanup_on_fail  = true
  set {
    name  = "installCRDs"
    value = "true"
  }
  set {
    name  = "global.leaderElection.namespace"
    value = "cert-manager"
  }
}

resource "helm_release" "actions-runner-controller" {
  name             = "actions-runner-controller"
  chart            = "actions-runner-controller"
  repository       = "https://actions-runner-controller.github.io/actions-runner-controller"
  namespace        = "actions-runner-system"
  version          = "0.23.3"
  create_namespace = true
  cleanup_on_fail  = true
  set {
    name  = "authSecret.create"
    value = "true"
  }
  set {
    name  = "authSecret.github_app_id"
    value = var.github-app-id
  }
  set {
    name  = "authSecret.github_app_installation_id"
    value = var.github-app-installation-id
  }
  set {
    name  = "authSecret.github_app_private_key"
    value = file("${var.github-app-private-key-file}")
  }
  depends_on = [ helm_release.cert-manager ]
}
