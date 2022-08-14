terraform {
  # https://www.terraform.io/downloads.html
  required_version = "1.2.7"

  required_providers {
    # https://registry.terraform.io/providers/hashicorp/azurerm/latest
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.18.0"
    }
  }

  backend "azurerm" {
    container_name = "provisioning"
    key            = "default/terraform"
  }
}

provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias           = "another"
  subscription_id = var.arm_subscription_id_another
  features {}
}
