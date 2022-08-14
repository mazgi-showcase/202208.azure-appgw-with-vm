output "azurerm_application_gateway" {
  value = {
    main = azurerm_application_gateway.main
  }
}
output "azurerm_linux_virtual_machine" {
  value = {
    vm-web-server = azurerm_linux_virtual_machine.vm-web-server
  }
}
