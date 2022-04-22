variable "prefix" {
  description = "A prefix used for all resources in this example"
}

variable "subscription_id" {
  type        = string
  description = "azure account subscription id "
}
####################### VNET ########################

variable "address_space" {
  type        = list(string)
  default     = ["10.1.0.0/16"]
  description = "address space of the vnet"
}

variable "service_endpoints" {
  type        = list(string)
  default     = ["Microsoft.Sql", "Microsoft.Storage"]
  description = "service endpoints for the subnet to allow"
}

variable "address_prefixes" {
  type        = list(string)
  default     = ["10.1.0.0/24"]
  description = "address prefixes for the subnet"
}

variable "delegated_subnet_address_prefix" {
  type        = list(string)
  default     = ["10.1.1.0/24"]
  description = "address prefixes for deleged subnet"
}

#############################  CLUSTER #################

variable "kubernetes_version" {
  type        = string
  default     = "1.21"
  description = "kubernetes version to be created"
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Azure AKS public API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "rg_name" {
  type        = string
  description = "azure resource group name"
}

variable "rg_location" {
  type        = string
  description = "azure resource group location"
}

############ default node pool 

variable "default_node_pool_name" {
  type        = string
  default     = "agentpool"
  description = "name of the default nodepool"
}

variable "default_node_pool_vm_size" {
  type        = string
  default     = "Standard_DS2_v2"
  description = "default nodepool vm size"
}

variable "default_pool_node_count" {
  type        = number
  default     = 2
  description = "number of nodes in default nodepool"
}

variable "availability_zones" {
  type        = list(string)
  default     = ["1", "2"]
  description = "availability zones for the nodes"
}

variable "max_pods_count" {
  type        = number
  default     = 80
  description = "maximum number of pods to be created"
}

variable "default_node_pool_os_disk_type" {
  type        = string
  default     = "Managed"
  description = "default nodepool os disk type"
}

variable "os_disk_size_gb" {
  type        = number
  default     = 128
  description = "os disk size in GB"
}

variable "default_node_pool_max_node_count" {
  type        = number
  default     = 5
  description = "Max number of nodes in a default node pool"
}

variable "default_node_pool_min_node_count" {
  type        = number
  default     = 2
  description = "Min number of nodes in a default node pool"
}

variable "identity_type" {
  type        = string
  default     = "SystemAssigned"
  description = "identity type of the vm"
}

variable "network_plugin" {
  type        = string
  default     = "kubenet"
  description = "network plugin type for the aks"
}

variable "load_balancer_sku" {
  type        = string
  default     = "standard"
  description = "loadbalancer sku type"
}

################# custom pool 

variable "jobfarm_pool_name" {
  type        = string
  default     = "small"
  description = "jobfarm nodepool name"
}

variable "jobfarmpool_vm_size" {
  type        = string
  default     = "Standard_D8as_v4"
  description = "jobfarm nodepool vm size"
}

variable "node_taints" {
  type        = list(string)
  default     = ["NodeType=ScannerNode:NoSchedule"]
  description = "jobfarm nodepool node taints"
}

variable "jobfarmpool_os_disk_type" {
  type        = string
  default     = "Ephemeral"
  description = "jobfarm nodepool os disk type"
}

variable "enable_auto_scaling" {
  type        = bool
  default     = true
  description = "it enables the cluster auto scalling if the value is true"
}

variable "node_labels" {
  description = "node labels to be attached to the nodes"
  type        = map(string)
  default = {
    "app" : "jobfarm",
    "pool-type" : "small"
  }
}

variable "jobfarmpool_min_count" {
  type        = number
  default     = 1
  description = "manimum nodes in jobfarm nodepool"
}

variable "jobfarmpool_max_count" {
  type        = number
  default     = 5
  description = "maximum nodes in jobfarm nodepool"
}

variable "jobfarmpool_node_count" {
  type        = number
  default     = 1
  description = "No of nodes in jobfarm nodepool"
}

variable "scanfarm_enabled" {
  type        = bool
  default     = false
  description = "to enable the scanfarm components"
}