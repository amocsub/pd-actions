variable "project" {
  default     = "king-platform-security-dev"
  description = "GCP project where to create the infraestructure"
}

variable "region" {
  default     = "europe-west1"
  description = "GCP region where to create the infraestructure"
}

# variable "shared-vpc-network" {
#   default     = "projects/king-sharedvpc-prod/global/networks/king-sharedvpc-prod-vpc"
#   description = "GCP Project Shared VPC network in king-sharedvpc-prod project"
# }

# variable "shared-vpc-subnet" {
#   default     = "projects/king-sharedvpc-prod/regions/europe-west1/subnetworks/king-platform-security-ci-subnet"
#   description = "GCP Project Shared VPC subnet in king-sharedvpc-prod project"
# }

variable "github-oidc-issuer" {
  default     = "https://token.actions.githubusercontent.com"
  description = "Github Host that would be able to authenticate to GCP, taken from https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

variable "github-org" {
  default     = "amocsub"
  description = "Github Organization allowed"
}

# variable "k8s-master-cidr-block" {
#   default     = "10.163.241.128/28"
#   description = "K8s cluster master CIDR block, taken from https://next-free-xvpc-peering.int.cloud.king.com/api "
# }