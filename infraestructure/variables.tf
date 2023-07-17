variable "project" {
  default     = "king-platform-security-dev"
  description = "GCP project where to create the infraestructure"
}

variable "region" {
  default     = "europe-west1"
  description = "GCP region where to create the infraestructure"
}

variable "github-oidc-issuer" {
  default     = "https://token.actions.githubusercontent.com"
  description = "Github Host that would be able to authenticate to GCP, taken from https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

variable "github-org" {
  default     = "amocsub"
  description = "Github Organization allowed"
}
