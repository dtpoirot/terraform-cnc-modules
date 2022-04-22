# output "namespace" {
#   value = local.namespace
# }

output "gcp_project_id" {
  value = var.gcp_project
}

output "gcp_cluster_name" {
  value = var.gcp_cluster_name
}

output "gcp_cluster_region" {
  value = var.gcp_region
}

## GCS outputs
output "gcs_bucket_name" {
  value = var.scanfarm_enabled ? google_storage_bucket.uploads-bucket[0].name : ""
}

output "coverity_cache_bucket_name" {
  value = var.scanfarm_enabled ? google_storage_bucket.coverity-cache-bucket[0].name : ""
}

output "gcs_bucket_region" {
  value = var.scanfarm_enabled ? var.bucket_region : ""
}

output "gcs_service_account" {
  value     = var.scanfarm_enabled ? base64decode(google_service_account_key.gcs_sa_key.0.private_key) : ""
  sensitive = true
}

## CloudSQL outputs
output "db_instance_address" {
  value = !local.is_cloudsql_instance_exist ? google_sql_database_instance.master.0.private_ip_address : ""
}

output "db_instance_username" {
  value = !local.is_cloudsql_instance_exist ? google_sql_user.user.0.name : ""
}

output "db_master_password" {
  value     = !local.is_cloudsql_instance_exist ? length(var.db_password) > 0 ? var.db_password : random_string.password.0.result : ""
  sensitive = true
}

output "db_instance_name" {
  value = !local.is_cloudsql_instance_exist ? google_sql_database_instance.master.0.name : ""
}

## Redis outputs
output "redis_host" {
  value = var.scanfarm_enabled ? google_redis_instance.coverity-cache[0].host : ""
}

output "redis_port" {
  value = var.scanfarm_enabled ? google_redis_instance.coverity-cache[0].port : ""
}

output "redis_server_ca_cert" {
  value     = var.scanfarm_enabled ? google_redis_instance.coverity-cache[0].server_ca_certs[0].cert : ""
  sensitive = true
}
