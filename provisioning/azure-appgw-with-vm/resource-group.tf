resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_unique_id}"
  location = var.azure_default_location
}
