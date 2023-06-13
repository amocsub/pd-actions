# variable "github-app-id" {
#   default     = "345920"
#   description = "The ID of your GitHub App."
# }

# variable "github-app-installation-id" {
#   default     = "38498118"
#   description = "The ID of your GitHub App installation."
# }

# variable "github-app-private-key-file" {
#   default     = "~/pd-actions.2023-06-11.private-key.pem"
#   description = "Filename where the multiline string of your GitHub App's private key is"
# }


variable "github-personal-access-token" {
    default = "***REMOVED***"
    description = "Github PAT to set-up the runners"
}