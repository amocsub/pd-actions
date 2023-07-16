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

resource "google_service_account_iam_binding" "pd-actions-k8s-role-binding" {
  service_account_id = google_service_account.pd-actions-k8s-sa.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:king-platform-security-ci.svc.id.goog[actions-runner-system/pd-actions-k8s-sa]",
  ]
  depends_on = [google_service_account.pd-actions-k8s-sa, google_iam_workload_identity_pool.pd-actions-wip]
}

# GCS Bucket
resource "google_storage_bucket" "pd-actions-bucket" {
  name     = "pd-actions-bucket-dev"
  location = "EU"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_member" "pd-actions-bucket-access-pd-actions-sa" {
  bucket     = google_storage_bucket.pd-actions-bucket.name
  role       = "roles/storage.objectAdmin"
  member     = "serviceAccount:${google_service_account.pd-actions-k8s-sa.email}"
  depends_on = [google_storage_bucket.pd-actions-bucket, google_service_account.pd-actions-k8s-sa]
}

# Workload Identity Pool & Provider
resource "google_iam_workload_identity_pool" "pd-actions-wip" {
  workload_identity_pool_id = "pd-actions-wip"
}

# Kubernetes Cluster
resource "google_iam_workload_identity_pool_provider" "github-enterprise" {
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
    issuer_uri = var.github-oidc-issuer
  }
  depends_on = [google_iam_workload_identity_pool.pd-actions-wip]
}

# Kubernetes Cluster
resource "google_container_cluster" "autopilot-primary" {
  name             = "autopilot-primary"
  location         = var.region
  enable_autopilot = true
  ip_allocation_policy {
  }
}