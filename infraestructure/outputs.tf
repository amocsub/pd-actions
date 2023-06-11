output "pd-actions-vpc-network-link" {
  value       = google_compute_network.pd-actions-vpc-network.self_link
  description = "Link to the created resource"
}

output "pd-actions-vpc-subnet" {
  value       = google_compute_subnetwork.pd-actions-vpc-subnet.self_link
  description = "Link to the created resource"
}

output "pd-actions-wip-sa" {
  value       = google_service_account.pd-actions-wip-sa.email
  description = "Service Account used in the cluster"
}

output "wip-pool" {
  value       = google_iam_workload_identity_pool.pd-actions-wip.id
  description = "Workload Identity Pool ID to be used"
}

output "get-cluster-credentials" {
  value       = "gcloud container clusters get-credentials autopilot-primary --region ${var.region} --project ${var.project}"
  description = "Run this command to get the created cluster credentials"
}

