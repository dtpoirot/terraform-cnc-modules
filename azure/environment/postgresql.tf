resource "random_string" "password" {
  count   = length(var.db_password) == 0 ? 1 : 0
  length  = 16
  special = false
}

resource "azurerm_postgresql_flexible_server" "master" {
  name                   = "${local.prefix}postgres"
  resource_group_name    = var.rg_name
  location               = var.rg_location
  version                = var.postgresql_version
  administrator_login    = var.db_username
  administrator_password = length(var.db_password) > 0 ? var.db_password : random_string.password.0.result
  storage_mb             = var.db_storage
  sku_name               = var.sku_name
  tags                   = var.tags
}

resource "azurerm_postgresql_flexible_server_configuration" "default" {
  name      = "require_secure_transport"
  server_id = azurerm_postgresql_flexible_server.master.id
  value     = "off"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "default" {
  name             = "${local.prefix}-postgres-fw-rule"
  server_id        = azurerm_postgresql_flexible_server.master.id
  start_ip_address = var.db_firewall_start_ip_address
  end_ip_address   = var.db_firewall_end_ip_address
}