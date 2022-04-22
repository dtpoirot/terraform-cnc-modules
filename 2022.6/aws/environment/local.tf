locals {
  ## Redis values
  default_redis_configs = {
    maxmemory-policy = "noeviction"
  }
  redis_configs = merge(local.default_redis_configs, var.redis_configs)
}
