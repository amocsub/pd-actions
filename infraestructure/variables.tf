variable "project" {
  default     = "pd-actions"
  description = "GCP project where to create the infraestructure"
}

variable "region" {
  default     = "europe-west1"
  description = "GCP region where to create the infraestructure"
}

variable "github-org" {
  default     = "amocsub"
  description = "Github Organization/User allowed in Workload Identity Federation"
}
