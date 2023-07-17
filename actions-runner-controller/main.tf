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

resource "helm_release" "actions-runner-controller-public" {
  name             = "actions-runner-controller-public"
  chart            = "actions-runner-controller"
  repository       = "https://actions-runner-controller.github.io/actions-runner-controller"
  namespace        = "actions-runner-system"
  version          = "0.23.3"
  create_namespace = true
  cleanup_on_fail  = true
  
  set_list {
    name = "labels"
    value = ["pd-actions"]
  }

  set {
    name = "authSecret.create"
    value = true
    type = "auto"
  }

  set_sensitive {
    name = "authSecret.github_app_id"
    value = var.github_app_id
  }

  set_sensitive {
    name = "authSecret.github_app_installation_id"
    value = var.github_app_installation_id
  }

  set_sensitive {
    name = "authSecret.github_app_private_key"
    value = file("${var.github_app_private_key}")
  }

  set {
    name = "image.actionsRunnerRepositoryAndTag"
    value = "buscoma/actions-runner:ubuntu-20.04"
  }

  set {
    name = "runner.statusUpdateHook.enabled"
    value = true
    type = "auto"
  }

  set {
    name = "serviceAccount.create"
    value = true
    type = "auto"
  }

  set {
    name = "serviceAccount.annotations.iam\\.gke\\.io/gcp-service-account"
    value = "pd-actions-k8s-sa@${var.project_id}.iam.gserviceaccount.com"
  }

  set {
    name = "serviceAccount.name"
    value = "pd-actions-k8s-sa"
  }

  set {
    name = "securityContext.privileged"
    value = false
    type = "auto"
  }

  set {
    name = "resources.requests.cpu"
    value = "8"
  }

  set {
    name = "resources.requests.memory"
    value = "16Gi"
  }

  set {
    name = "resources.requests.ephemeral-storage"
    value = "10Gi"
  }

  set {
    name = "githubWebhookServer.enabled"
    value = true
    type = "auto"
  }

  set {
    name = "githubWebhookServer.service.type"
    value = "LoadBalancer"
  }

  set {
    name = "githubWebhookServer.service.annotations.cloud\\.google\\.com/load-balancer-type"
    value = "External"
  }

  set_sensitive {
    name = "githubWebhookServer.secret.github_webhook_secret_token"
    value = var.github_webhook_secret_token
  }

  depends_on = [helm_release.cert-manager]
}

resource "kubernetes_manifest" "runner-deployment" {
  manifest = {
    "apiVersion" = "actions.summerwind.dev/v1alpha1"
    "kind"       = "RunnerDeployment"
    "metadata" = {
      "name"      = "pd-actions-amocsub"
      "namespace" = "actions-runner-system"
    }
    "spec" = {
      "template" = {
        "spec" = {
          "serviceAccountName" = "pd-actions-k8s-sa"
          "repository" = "amocsub/pd-actions"
          "labels" = ["pd-actions"]
          "dockerEnabled" = false
          "resources" = {
            "requests" = {
              "cpu" = "4"
              "memory" = "8Gi"
              "ephemeral-storage" = "10Gi"
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.actions-runner-controller-public]
}

resource "kubernetes_manifest" "horizontal-runner-autoscaler" {
  manifest = {
    "apiVersion" = "actions.summerwind.dev/v1alpha1"
    "kind" = "HorizontalRunnerAutoscaler"
    "metadata" = {
      "name" = "pd-actions-amocsub-autoscaler"
      "namespace" = "actions-runner-system"
    }
    "spec" = {
      "minReplicas" = 1
      "maxReplicas" = 256
      "scaleTargetRef" = {
        "kind" = "RunnerDeployment"
        "name" = "pd-actions-amocsub"
      }
      "scaleUpTriggers" = [
        {
          "githubEvent" = {
            "workflowJob" = {}
          }
          "duration" = "30m"
        }
      ]
    }
  }

  depends_on = [kubernetes_manifest.runner-deployment]
}
