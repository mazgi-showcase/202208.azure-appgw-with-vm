resource "azurerm_network_security_group" "main" {
  name                = "${var.project_unique_id}-main"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = {}
}

resource "azurerm_network_security_rule" "allow_azure_gwmgr" {
  name                        = "${var.project_unique_id}-allow_azure_gwmgr"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "65200-65535"
  source_address_prefix       = "GatewayManager"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "allow_from_allowed_list" {
  name                        = "${var.project_unique_id}-allow_from_allowed_list"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes     = var.allowed_ipaddr_list
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "allow_from_manual_update" {
  name                        = "${var.project_unique_id}-allow_from_manual_update"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes     = ["255.255.255.255/32"]
  destination_address_prefix  = "*"
  lifecycle {
    ignore_changes = [
      source_address_prefix,
      source_address_prefixes,
    ]
  }
  description = "You can update this rule manually."
}
