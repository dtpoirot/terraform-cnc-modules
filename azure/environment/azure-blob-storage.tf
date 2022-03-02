resource "azurerm_storage_account" "storage_account" {
  count                    = var.scanfarm_enabled ? 1 : 0
  name                     = "${local.prefix}storageac"
  resource_group_name      = var.rg_name
  location                 = var.rg_location
  account_tier             = "Standard"
  account_replication_type = var.storage_account_replication_type
  tags                     = var.tags
}

resource "azurerm_storage_account_network_rules" "default" {
  count                      = var.scanfarm_enabled ? 1 : 0
  storage_account_id         = azurerm_storage_account.storage_account[0].id
  default_action             = "Allow"
  ip_rules                   = var.storage_firewall_ip_rules
  virtual_network_subnet_ids = var.vnet_subnetid
  bypass                     = ["AzureServices"]
}

resource "azurerm_storage_container" "uploads_bucket" {
  count                 = var.scanfarm_enabled ? 1 : 0
  name                  = "${local.prefix}-uploads-bucket"
  storage_account_name  = azurerm_storage_account.storage_account[0].name
  container_access_type = "private"
}
