module "azure-appgw-with-vm" {
  source                 = "./azure-appgw-with-vm"
  project_unique_id      = "${var.project_unique_id}-azure-appgw-with-vm"
  allowed_ipaddr_list    = var.allowed_ipaddr_list
  azure_default_location = var.azure_default_location
}
