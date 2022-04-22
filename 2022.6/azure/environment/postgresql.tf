resource "random_string" "password" {
  count   = length(var.db_password) == 0 ? 1 : 0
  length  = 16
  special = false
}

resource "azurerm_private_dns_zone" "private_dns" {
  name                = "${local.prefix}.postgres.database.azure.com"
  resource_group_name = var.rg_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_vlink" {
  name                  = "privateVnetZone"
  private_dns_zone_name = azurerm_private_dns_zone.private_dns.name
  virtual_network_id    = var.vnet_id
  resource_group_name   = var.rg_name
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
  zone                   = "1"
  delegated_subnet_id    = var.delegated_subnet_id
  private_dns_zone_id    = azurerm_private_dns_zone.private_dns.id
  depends_on             = [azurerm_private_dns_zone_virtual_network_link.private_vlink]
}

resource "azurerm_postgresql_flexible_server_configuration" "default" {
  name      = "require_secure_transport"
  server_id = azurerm_postgresql_flexible_server.master.id
  value     = "off"
}

resource "azurerm_postgresql_flexible_server_configuration" "extensions" {
  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.master.id
  value     = "UUID-OSSP"
}