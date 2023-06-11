variable "project" {
  default     = "pd-actions"
  description = "GCP project where to create the infraestructure"
}

variable "region" {
  default     = "europe-west1"
  description = "GCP region where to create the infraestructure"
}

variable "github-enterprise-host" {
  default     = ""
  description = "Github Enterprise Host that would be able to authenticate to GCP, leave it with the default value empty if you are connecting from Github.com"
}

variable "github-org" {
  default     = "amocsub"
  description = "Github Organization/User allowed in Workload Identity Federation"
}
