terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.10.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.21.1"
    }
  }
}
provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "gke_king-platform-security-dev_europe-west1_autopilot-primary"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "gke_king-platform-security-dev_europe-west1_autopilot-primary"
}