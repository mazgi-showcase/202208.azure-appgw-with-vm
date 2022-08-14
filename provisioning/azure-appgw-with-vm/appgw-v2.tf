resource "azurerm_public_ip" "for_main_appgw" {
  name                = "for-main-appgw"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

locals {
  backend_address_pool_base_name        = "backend"
  backend_http_settings_base_name       = "setting"
  frontend_ip_configuration_public_name = "ip_config_public"
  frontend_http_port_name               = "port_http"
  http_listener_basic_public_base_name  = "http_listener_basic_public"
  probe_name                            = "probe"
}
resource "azurerm_application_gateway" "main" {
  name                = "main"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  dynamic "backend_address_pool" {
    for_each = var.colors
    content {
      name = "${local.backend_address_pool_base_name}-${backend_address_pool.key}"
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.colors
    content {
      name                  = "${local.backend_http_settings_base_name}-${backend_http_settings.key}"
      cookie_based_affinity = "Disabled"
      host_name             = "${backend_http_settings.key}.example.com"
      port                  = 80
      protocol              = "Http"
      request_timeout       = 60
      probe_name            = local.probe_name
    }
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_public_name
    public_ip_address_id = azurerm_public_ip.for_main_appgw.id
  }

  frontend_port {
    name = local.frontend_http_port_name
    port = 80
  }

  gateway_ip_configuration {
    name      = "gw_ip_config0"
    subnet_id = azurerm_subnet.appgw.id
  }

  dynamic "http_listener" {
    for_each = var.colors
    content {
      name                           = "${local.http_listener_basic_public_base_name}-${http_listener.key}"
      frontend_ip_configuration_name = local.frontend_ip_configuration_public_name
      frontend_port_name             = local.frontend_http_port_name
      host_names = [
        "${http_listener.key}.example.com",
        "*.${http_listener.key}.example.com",
      ]
      protocol = "Http"
    }
  }

  probe {
    name                                      = local.probe_name
    protocol                                  = "Http"
    path                                      = "/"
    interval                                  = 30
    unhealthy_threshold                       = 3
    timeout                                   = 30
    pick_host_name_from_backend_http_settings = true
    match {
      status_code = ["200-399"]
      body        = ""
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.colors
    content {
      name                       = "rule_http_public_${request_routing_rule.key}"
      priority                   = index(tolist(var.colors), request_routing_rule.key) + 1
      rule_type                  = "Basic"
      http_listener_name         = "${local.http_listener_basic_public_base_name}-${request_routing_rule.key}"
      backend_address_pool_name  = "${local.backend_address_pool_base_name}-${request_routing_rule.key}"
      backend_http_settings_name = "${local.backend_http_settings_base_name}-${request_routing_rule.key}"
    }
  }

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }
}
