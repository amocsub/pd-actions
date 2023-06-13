terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.10.1"
    }
  }
}
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = "gke_pd-actions_europe-west1_autopilot-primary"
  }
}