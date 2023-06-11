# Network and Sub-Network
resource "google_compute_network" "pd-actions-vpc-network" {
  name                    = "pd-actions-vpc-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "pd-actions-vpc-subnet" {
  name          = "pd-actions-vpc-subnet"
  ip_cidr_range = "10.0.0.0/23"
  network       = google_compute_network.pd-actions-vpc-network.id
  secondary_ip_range = [
    {
      range_name    = "k8s-pods"
      ip_cidr_range = "240.0.0.0/16"
    },
    {
      range_name    = "k8s-svc"
      ip_cidr_range = "240.1.0.0/22"
    }
  ]
  depends_on = [google_compute_network.pd-actions-vpc-network]
}

# Service Account & Role Binding
resource "google_service_account" "pd-actions-wip-sa" {
  account_id = "pd-actions-wip-sa"
}

resource "google_service_account_iam_binding" "pd-actions-wip-role-binding" {
  service_account_id = google_service_account.pd-actions-wip-sa.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.pd-actions-wip.name}/attribute.repository_owner/${var.github-org}",
  ]
  depends_on = [google_service_account.pd-actions-wip-sa, google_iam_workload_identity_pool.pd-actions-wip]
}

resource "google_service_account" "pd-actions-k8s-sa" {
  account_id = "pd-actions-k8s-sa"
}

# Workload Identity Pool & Provider
resource "google_iam_workload_identity_pool" "pd-actions-wip" {
  workload_identity_pool_id = "pd-actions-wip"
}

# Kubernetes Cluster
resource "google_iam_workload_identity_pool_provider" "github-wip-provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.pd-actions-wip.workload_identity_pool_id
  workload_identity_pool_provider_id = "github"
  display_name                       = "Github"
  description                        = "Github OIDC provider"
  disabled                           = false
  attribute_mapping = {
    "attribute.repository_owner" = "assertion.repository_owner",
    "google.subject"             = "assertion.sub"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
  depends_on = [google_iam_workload_identity_pool.pd-actions-wip]
}

# Kubernetes Cluster Public
resource "google_container_cluster" "autopilot-primary" {
  name             = "autopilot-primary"
  location         = var.region
  enable_autopilot = true
  network          = google_compute_network.pd-actions-vpc-network.id
  subnetwork       = google_compute_subnetwork.pd-actions-vpc-subnet.id
  ip_allocation_policy {
    cluster_secondary_range_name  = "k8s-pods"
    services_secondary_range_name = "k8s-svc"
  }
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_global_access_config {
      enabled = true
    }
  }
  depends_on = [ google_compute_network.pd-actions-vpc-network, google_compute_subnetwork.pd-actions-vpc-subnet ]
}