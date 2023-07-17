variable "github_app_id" {
  default     = "345920"
  description = "The ID of your GitHub App."
}

variable "github_app_installation_id" {
  default     = "38498118"
  description = "The ID of your GitHub App installation."
}

variable "github_app_private_key" {
  default     = "~/pd-actions.private-key.pem"
  description = "GitHub App's private key data"
}

variable "project_id" {
  default     = "king-platform-security-dev"
  description = "GCP project_id"
}

variable "github_webhook_secret_token" {
  default     = "MLUYysDrbe3eTrBOdz1dL3TBFZ99S9kEztcL2xZq"
  description = "GitHub WebHook Secret Token"
}