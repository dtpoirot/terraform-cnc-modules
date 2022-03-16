locals {
  random_prefix = "${var.prefix}-${random_id.dns_prefix.hex}"
}

data "azurerm_kubernetes_service_versions" "current" {
  location       = var.rg_location
  version_prefix = var.kubernetes_version
}

resource "random_id" "dns_prefix" {
  byte_length = 3
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                            = "${var.prefix}-cluster"
  resource_group_name             = var.rg_name
  location                        = var.rg_location
  dns_prefix                      = "${local.random_prefix}-cluster"
  kubernetes_version              = data.azurerm_kubernetes_service_versions.current.latest_version
  api_server_authorized_ip_ranges = var.cluster_endpoint_public_access_cidrs
  default_node_pool {
    name               = var.default_node_pool_name
    vm_size            = var.default_node_pool_vm_size
    type               = "VirtualMachineScaleSets"
    node_count         = var.default_pool_node_count
    availability_zones = var.availability_zones
    max_pods           = var.max_pods_count

    os_disk_type    = var.default_node_pool_os_disk_type
    os_disk_size_gb = var.os_disk_size_gb
    max_count       = var.default_node_pool_max_node_count
    min_count       = var.default_node_pool_min_node_count

    enable_auto_scaling = true
    vnet_subnet_id      = azurerm_subnet.subnet.id
  }

  identity {
    type = var.identity_type
  }
  role_based_access_control {
    enabled = true
  }
  network_profile {
    network_plugin    = var.network_plugin
    load_balancer_sku = var.load_balancer_sku
    pod_cidr = var.pod_cidr
  }
  addon_profile {
    http_application_routing {
      enabled = true
    }
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "jobfarmpool" {
  count                 = var.scanfarm_enabled ? 1 : 0
  name                  = var.jobfarm_pool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.jobfarmpool_vm_size
  node_count            = var.jobfarmpool_node_count
  os_type               = "Linux"
  os_disk_type          = var.jobfarmpool_os_disk_type
  mode                  = "User"
  node_taints           = var.node_taints
  min_count             = var.jobfarmpool_min_count
  max_count             = var.jobfarmpool_max_count
  availability_zones    = var.availability_zones
  enable_auto_scaling   = var.enable_auto_scaling
  node_labels           = var.node_labels
}



