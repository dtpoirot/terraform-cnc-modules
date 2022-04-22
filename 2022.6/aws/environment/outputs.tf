## S3 outputs
output "s3_bucket_name" {
  value = local.is_bucket_exist ? data.aws_s3_bucket.default.0.id : module.s3_bucket.s3_bucket_id
}

output "coverity_cache_bucket_name" {
  value = var.scanfarm_enabled ? module.coverity-cache-bucket.s3_bucket_id : ""
}

output "s3_bucket_region" {
  value = local.is_bucket_exist ? data.aws_s3_bucket.default.0.region : module.s3_bucket.s3_bucket_region
}

## RDS outputs
output "db_instance_address" {
  value = local.is_rds_instance_exist ? data.aws_db_instance.default.0.address : module.rds.db_instance_address
}

output "db_instance_port" {
  value = local.is_rds_instance_exist ? data.aws_db_instance.default.0.port : module.rds.db_instance_port
}

output "db_instance_username" {
  value     = local.is_rds_instance_exist ? data.aws_db_instance.default.0.master_username : module.rds.db_instance_username
  sensitive = true
}

output "db_master_password" {
  value     = local.is_rds_instance_exist ? var.db_password : module.rds.db_master_password
  sensitive = true
}

output "db_instance_name" {
  value = local.is_rds_instance_exist ? data.aws_db_instance.default.0.db_name : module.rds.db_instance_name
}

output "db_subnet_group_id" {
  value = local.is_rds_instance_exist ? data.aws_db_instance.default.0.db_subnet_group : module.rds.db_subnet_group_id
}


# output "namespace" {
#   value = replace(lower(var.prefix), "/[^a-zA-Z0-9]/", "")
# }

output "cluster_name" {
  value = var.cluster_name
}

output "cluster_region" {
  value = var.aws_region
}

## Redis outputs
output "redis_host" {
  value = var.scanfarm_enabled ? module.elasticache-redis.endpoint : ""
}

output "redis_port" {
  value = var.scanfarm_enabled ? module.elasticache-redis.port : ""
}

output "redis_password" {
  value     = var.scanfarm_enabled ? random_string.redis-password.0.result : ""
  sensitive = true
}
