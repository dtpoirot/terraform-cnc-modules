variable "prefix" {
  description = "A prefix used for all resources in this example"
}

variable "rg_location" {
  description = "The Azure Region in which all resources in this example should be provisioned"
}

variable "subscription_id" {
  type        = string
  description = "azure account subscription id"
}

variable "rg_name" {
  description = "name of the azure resource group"
}

variable "db_username" {
  type        = string
  description = "Username for the master DB user. Note: Do NOT use 'user' as the value"
  default     = "postgres"
}

variable "db_password" {
  type        = string
  description = "Password for the master DB user; If empty, then random password will be set by default. Note: This will be stored in the state file"
  default     = ""
}

variable "postgresql_version" {
  type        = string
  description = "postgresql DB version"
  default     = "13"
}

variable "db_name" {
  type        = string
  description = "Name of the postgres instance; if empty, then CloudSQL instance will be created"
  default     = ""
}

variable "vnet_subnetid" {
  type        = string
  description = "subnet id to attach with the storage account"
  default     = ""
}

variable "vnet_id" {
   type = string
   default = ""
}

variable "delegated_subnet_id" {
  type=  string
  default = ""
}

variable "storage_firewall_ip_rules" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "azure storage account firewall rules"
}

variable "storage_account_replication_type" {
  type        = string
  default     = "GRS"
  description = "azure stotage account replication type"
}

variable "scanfarm_enabled" {
  type        = bool
  default     = false
  description = "to enable the scanfarm components"
}

variable "tags" {
  type        = map(string)
  description = "azure Tags to add to all resources created (wherever possible)"
  default = {
    product    = "cnc"
    automation = "dns"
    managedby  = "terraform"
  }
}

variable "sku_name" {
  description = "postgres sku_name "
  default     = "GP_Standard_D4s_v3"
}

variable "db_storage" {
  description = "db storage size in mb"
  type        = number
  default     = 32768
}

variable "az_cluster_name" {
  description = "azure cluster name"
  type        = string
}

variable "ingress_white_list_ip_ranges" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "deploy_ingress_controller" {
  type        = bool
  description = "Flag to enable/disable the nginx-ingress-controller deployment in the GKE cluster"
  default     = true
}

variable "ingress_controller_helm_chart_version" {
  type        = string
  description = "Version of the nginx-ingress-controller helm chart"
  default     = "3.35.0"
}

variable "ingress_settings" {
  type        = map(string)
  description = "Additional settings which will be passed to the Helm chart values, see https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx"
  default     = {}
}

variable "ingress_namespace" {
  type        = string
  description = "Namespace in which ingress controller should be deployed. If empty, then ingress-controller will be created"
  default     = ""
}
