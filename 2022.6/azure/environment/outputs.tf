output "azure_resource_group_name" {
  value = var.rg_name
}

output "aks_cluster_name" {
  value = var.az_cluster_name
}

output "azure_resource_group_location" {
  value = var.rg_location
}

## Azure storage outputs
output "storage_bucket_name" {
  value = var.scanfarm_enabled ? resource.azurerm_storage_container.uploads_bucket[0].name : ""
}

output "storage_account_name" {
  value = var.scanfarm_enabled ? resource.azurerm_storage_account.storage_account[0].name : ""
}

output "storage_access_key" {
  value     = var.scanfarm_enabled ? resource.azurerm_storage_account.storage_account[0].primary_access_key : ""
  sensitive = true
}

## Postgres outputs
output "db_instance_address" {
  value = resource.azurerm_postgresql_flexible_server.master.fqdn
}

output "db_instance_username" {
  value     = resource.azurerm_postgresql_flexible_server.master.administrator_login
  sensitive = true
}

output "db_master_password" {
  value     = resource.azurerm_postgresql_flexible_server.master.administrator_password
  sensitive = true
}

output "db_instance_name" {
  value = resource.azurerm_postgresql_flexible_server.master.id
}