resource "azurerm_redis_cache" "coverity-cache" {
  count                         = var.scanfarm_enabled ? 1 : 0
  name                          = "${local.prefix}-coverity-cache"
  resource_group_name           = var.rg_name
  location                      = var.rg_location
  redis_version                 = var.redis_version
  capacity                      = var.redis_capacity
  family                        = var.redis_family
  sku_name                      = var.redis_sku_name
  enable_non_ssl_port           = false
  public_network_access_enabled = true
  minimum_tls_version           = "1.2"
  tags                          = var.tags

  redis_configuration {
    maxmemory_policy = "noeviction"
  }
}
