variable "project_unique_id" {}

variable "allowed_ipaddr_list" {
  type = list(any)
}

variable "base_dnsdomain" {
  default = "example.dev"
}

# variable "aws_default_region" {}
# variable "aws_access_key" {}
# variable "aws_secret_key" {}

variable "azure_default_location" {}

# variable "gcp_default_region" {
#   default = "us-central1"
# }
# variable "gcp_project_id" {}
