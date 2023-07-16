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
  
  values = [
    "${file("values.yaml")}"
  ]

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
