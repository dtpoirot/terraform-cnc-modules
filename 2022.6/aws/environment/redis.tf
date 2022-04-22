data "aws_availability_zones" "available" {
}

resource "random_string" "redis-password" {
  count   = var.scanfarm_enabled ? 1 : 0
  length  = 16
  special = false
}

module "this" {
  source    = "cloudposse/label/null"
  version   = "0.25.0"
  namespace = local.namespace
  stage     = "prod"
  name      = "redis"
}

module "elasticache-redis" {
  source                = "cloudposse/elasticache-redis/aws"
  version               = "0.42.0"
  enabled               = var.scanfarm_enabled
  availability_zones    = data.aws_availability_zones.available.names
  vpc_id                = var.vpc_id
  subnets               = var.vpc_private_subnets
  create_security_group = true
  allow_all_egress      = false

  additional_security_group_rules = [{
    type        = "ingress"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = var.db_vpc_cidr_blocks
  }]

  cluster_size               = var.redis_cluster_size
  instance_type              = var.redis_instance_type
  apply_immediately          = true
  automatic_failover_enabled = false
  engine_version             = var.redis_engine_version
  family                     = var.redis_family
  auth_token                 = random_string.redis-password.0.result
  transit_encryption_enabled = true
  context                    = module.this.context
  tags                       = var.tags

  parameter = [
    for key, value in local.redis_configs :
    { "name" = key, "value" = value }
  ]
}
