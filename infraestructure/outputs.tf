output "get-cluster-credentials" {
  value       = "gcloud container clusters get-credentials autopilot-primary --region ${var.region} --project ${var.project}"
  description = "Run this command to get the created cluster credentials"
}

