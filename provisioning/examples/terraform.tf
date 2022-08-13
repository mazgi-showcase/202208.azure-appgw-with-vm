# --------------------------------
# Terraform configuration

terraform {
  # https://www.terraform.io/downloads.html
  required_version = "1.1.6"

  required_providers {
    # https://registry.terraform.io/providers/hashicorp/aws/latest
    aws = {
      source  = "hashicorp/aws"
      version = "=4.2.0"
    }
    # https://registry.terraform.io/providers/hashicorp/azurerm/latest
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.97.0"
    }
    # https://registry.terraform.io/providers/hashicorp/google/latest
    google = {
      source  = "hashicorp/google"
      version = "=4.11.0"
    }
    # https://registry.terraform.io/providers/hashicorp/google-beta/latest
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "=4.11.0"
    }
  }

  backend "azurerm" {
    container_name = "provisioning"
    key            = "default/terraform"
  }
  # backend "gcs" {
  #   prefix = "default/terraform"
  # }
}

# provider "aws" {
#   access_key = var.aws_access_key
#   secret_key = var.aws_secret_key
#   region     = var.aws_default_region
# }

provider "azurerm" {
  features {}
}

# provider "google" {
#   project = var.gcp_project_id
#   region  = var.gcp_default_region
#   zone    = "${var.gcp_default_region}-a"
# }

# provider "google-beta" {
#   project = var.gcp_project_id
#   region  = var.gcp_default_region
#   zone    = "${var.gcp_default_region}-a"
# }
