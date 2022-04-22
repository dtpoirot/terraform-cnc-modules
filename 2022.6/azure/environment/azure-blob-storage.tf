# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
resource "azurerm_storage_account" "storage_account" {
  count                    = var.scanfarm_enabled ? 1 : 0
  name                     = "${local.prefix}storageac"
  resource_group_name      = var.rg_name
  location                 = var.rg_location
  account_tier             = "Standard"
  account_replication_type = var.storage_account_replication_type
  network_rules {
    default_action             = "Deny"
    ip_rules                   = var.storage_firewall_ip_rules
    virtual_network_subnet_ids = [var.vnet_subnetid]
    bypass                     = ["AzureServices"]
  }
  tags = var.tags
}

resource "azurerm_storage_container" "uploads_bucket" {
  count                 = var.scanfarm_enabled ? 1 : 0
  name                  = "${local.prefix}-uploads-bucket"
  storage_account_name  = azurerm_storage_account.storage_account[0].name
  container_access_type = "private"
}

resource "azurerm_storage_container" "coverity_cache_bucket" {
  count                 = var.scanfarm_enabled ? 1 : 0
  name                  = "${local.prefix}-coverity-cache-bucket"
  storage_account_name  = azurerm_storage_account.storage_account[0].name
  container_access_type = "private"
}

resource "azurerm_storage_management_policy" "coverity_cache_bucket" {
  count              = var.scanfarm_enabled ? 1 : 0
  storage_account_id = azurerm_storage_account.storage_account[0].id
  rule {
    name    = "${local.prefix}-coverity-cache-bucket-expiration"
    enabled = true
    filters {
      prefix_match = [resource.azurerm_storage_container.coverity_cache_bucket[0].name]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = var.coverity_cache_age
      }
    }
  }
}
