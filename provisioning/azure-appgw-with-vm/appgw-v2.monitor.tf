resource "azurerm_monitor_diagnostic_setting" "for_main_appgw" {
  name                       = "for-main-appgw"
  target_resource_id         = azurerm_application_gateway.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  log {
    category = "ApplicationGatewayAccessLog"
    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "ApplicationGatewayFirewallLog"
    enabled  = false
    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "ApplicationGatewayPerformanceLog"
    retention_policy {
      days    = 0
      enabled = false
    }
  }
  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }
}
