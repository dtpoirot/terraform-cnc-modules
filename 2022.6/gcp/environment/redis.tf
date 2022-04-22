resource "google_redis_instance" "coverity-cache" {
  count                   = var.scanfarm_enabled ? 1 : 0
  name                    = substr("${local.namespace}-coverity-cache", 0, 40)
  display_name            = "${local.namespace} coverity redis cache"
  redis_version           = var.redis_version
  tier                    = var.redis_tier
  authorized_network      = var.gcp_network_self_link
  labels                  = var.tags
  memory_size_gb          = var.redis_memory_size_gb
  redis_configs           = local.redis_configs
  transit_encryption_mode = "SERVER_AUTHENTICATION"

  timeouts {
    create = "30m"
    update = "30m"
    delete = "60m"
  }
}
