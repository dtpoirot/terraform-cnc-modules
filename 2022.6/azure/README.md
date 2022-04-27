# Coverity on Azure: reference implementation

Terraform creates the below AZURE cloud resources by using the individual modules.

- [global-resources](./global-resources): This module will create the VNET, subnetwork and AKS cluster.
- [environment](./environment): This module will create the Postgresql server, Redis instance, azure-blob-storage containers(if scanfarm_enabled is true) and deploy nginx-ingress-controller in it

## Global resources
### Inputs
| Name                                 | Description                                                                    | Type           | Default                                  | Required |
|--------------------------------------|--------------------------------------------------------------------------------|----------------|------------------------------------------|--------|
| prefix                               | A prefix used for all resources in this example                                | `string`       | ``                                       | yes    |
| subscription_id                      | azure account subscription id                                                  | `string`       | ``                                       | yes    |
| address_space                        | address space of the vnet                                                      | `list("string")` | `['10.1.0.0/16']`                        | no     |
| service_endpoints                    | service endpoints for the subnet to allow                                      | `list("string")` | `['Microsoft.Sql', 'Microsoft.Storage']` | no     |
| address_prefixes                     | address prefixes for the subnet                                                | `list("string")` | `['10.1.0.0/24']`                        | no     |
| delegated_subnet_address_prefix      | address prefixes for deleged subnet                                            | `list("string")` | `['10.1.1.0/24']`                        | no     |
| kubernetes_version                   | kubernetes version to be created                                               | `string`       | `1.21`                                   | no     |
| cluster_endpoint_public_access_cidrs | List of CIDR blocks which can access the Azure AKS public API server endpoint. | `list("string")` | `['0.0.0.0/0']`                          | no     |
| rg_name                              | azure resource group name                                                      | `string`       | ``                                       | yes    |
| rg_location                          | azure resource group location                                                  | `string`       | ``                                       | yes    |
| default_node_pool_name               | name of the default nodepool                                                   | `string`       | `agentpool`                              | no     |
| default_node_pool_vm_size            | default nodepool vm size                                                       | `string`       | `Standard_DS2_v2`                        | no     |
| default_pool_node_count              | number of nodes in default nodepool                                            | `number`       | `2`                                      | no     |
| availability_zones                   | availability zones for the nodes                                               | `list("string")` | `['1', '2']`                             | no     |
| max_pods_count                       | maximum number of pods to be created                                           | `number`       | `80`                                     | no     |
| default_node_pool_os_disk_type       | default nodepool os disk type                                                  | `string`       | `Managed`                                | no     |
| os_disk_size_gb                      | os disk size in GB                                                             | `number`       | `128`                                    | no     |
| default_node_pool_max_node_count     | Max number of nodes in a default node pool                                     | `number`       | `5`                                      | no     |
| default_node_pool_min_node_count     | Min number of nodes in a default node pool                                     | `number`       | `2`                                      | no     |
| identity_type                        | identity type of the vm                                                        | `string`       | `SystemAssigned`                         | no     |
| network_plugin                       | network plugin type for the aks                                                | `string`       | `kubenet`                                | no     |
| load_balancer_sku                    | loadbalancer sku type                                                          | `string`       | `standard`                               | no     |
| jobfarm_pool_name                    | jobfarm nodepool name                                                          | `string`       | `small`                                  | no     |
| jobfarmpool_vm_size                  | jobfarm nodepool vm size                                                       | `string`       | `Standard_D8as_v4`                       | no     |
| node_taints                          | jobfarm nodepool node taints                                                   | `list("string")` | `['NodeType=ScannerNode:NoSchedule']`    | no     |
| jobfarmpool_os_disk_type             | jobfarm nodepool os disk type                                                  | `string`       | `Ephemeral`                              | no     |
| enable_auto_scaling                  | it enables the cluster auto scalling if the value is true                      | `bool`         | `true`                                   | no     |
| node_labels                          | node labels to be attached to the nodes                                        | `map("string")` | `{'app': 'jobfarm', 'pool-type': 'small'}` | no     |
| jobfarmpool_min_count                | manimum nodes in jobfarm nodepool                                              | `number`       | `1`                                      | no     |
| jobfarmpool_max_count                | maximum nodes in jobfarm nodepool                                              | `number`       | `5`                                      | no     |
| jobfarmpool_node_count               | No of nodes in jobfarm nodepool                                                | `number`       | `1`                                      | no     |
| scanfarm_enabled                     | to enable the scanfarm components                                              | `bool`         | `false`                                  | no     |

### Outputs
| Name | Description |
|------|-------------|
| rg_name | The name of the resource group in which resources are created |
| rg_location | The location of the resource group in which resources are created |
| vnet_name | The name of the virtual network |
| vnet_id | The ID of the created virtual network |
| subnetid | The subnet id of the created virtual network |
| delegated_subnet_id | The delegated subnet_id, which is used to create private network link for postgresql server |
| publicip | The NAT IP |
| cluster_name | The name of the AKS cluster created |

## Environment resources
### Inputs
| Name                                  | Description                                                                                          | Type           | Default                                  | Required |
|---------------------------------------|------------------------------------------------------------------------------------------------------|----------------|------------------------------------------|--------|
| prefix                                | A prefix used for all resources in this example                                                      | `string`       | ``                                       | yes    |
| rg_location                           | The Azure Region in which all resources in this example should be provisioned                        | `string`       | ``                                       | yes    |
| subscription_id                       | azure account subscription id                                                                        | `string`       | ``                                       | yes    |
| rg_name                               | name of the azure resource group                                                                     | `string`       | ``                                       | yes    |
| db_username                           | Username for the master DB user. Note: Do NOT use 'user' as the value                                | `string`       | `postgres`                               | no     |
| db_password                           | Password for the master DB user; If empty, then random password will be set by default. Note: This will be stored in the state file | `string`       | `""`                                     | no     |
| postgresql_version                    | postgresql DB version                                                                                | `string`       | `13`                                     | no     |
| db_name                               | Name of the postgres instance; if empty, then CloudSQL instance will be created                      | `string`       | `""`                                     | no     |
| vnet_subnetid                         | subnet id to attach with the storage account                                                         | `string`       | `""`                                     | no     |
| vnet_id                               |                                                                                                      | `string`       | `""`                                     | no     |
| delegated_subnet_id                   |                                                                                                      | `string`       | `""`                                     | no     |
| storage_firewall_ip_rules             | azure storage account firewall rules                                                                 | `list("string")` | `['0.0.0.0/0']`                          | no     |
| storage_account_replication_type      | azure stotage account replication type                                                               | `string`       | `GRS`                                    | no     |
| scanfarm_enabled                      | to enable the scanfarm components                                                                    | `bool`         | `false`                                  | no     |
| tags                                  | azure Tags to add to all resources created (wherever possible)                                       | `map("string")` | `{'product': 'cnc', 'automation': 'dns', 'managedby': 'terraform'}` | no     |
| sku_name                              | postgres sku_name                                                                                    | `string`       | `GP_Standard_D4s_v3`                     | no     |
| db_storage                            | db storage size in mb                                                                                | `number`       | `32768`                                  | no     |
| az_cluster_name                       | azure cluster name                                                                                   | `string`       | ``                                       | yes    |
| ingress_white_list_ip_ranges          |                                                                                                      | `list("string")` | `['0.0.0.0/0']`                          | no     |
| deploy_ingress_controller             | Flag to enable/disable the nginx-ingress-controller deployment in the GKE cluster                    | `bool`         | `true`                                   | no     |
| ingress_controller_helm_chart_version | Version of the nginx-ingress-controller helm chart                                                   | `string`       | `3.35.0`                                 | no     |
| ingress_settings                      | Additional settings which will be passed to the Helm chart values, see https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx | `map("string")` | `{}`                                     | no     |
| ingress_namespace                     | Namespace in which ingress controller should be deployed. If empty, then ingress-controller will be created | `string`       | `""`                                     | no     |
| coverity_cache_age                    | No.of days for expiration of Azure storage blobs in coverity-cache-bucket. Should be atleast 3 days  | `number`       | `15`                                     | no     |
| redis_capacity                        | The size of the Redis cache to deploy. Valid values for a SKU family of C (Basic/Standard) are 0, 1, 2, 3, 4, 5, 6 | `number`       | `2`                                      | no     |
| redis_version                         | Redis version                                                                                        | `string`       | `6`                                      | no     |
| redis_family                          | The SKU family/pricing group to use. Valid values are C (for Basic/Standard SKU family) and P (for Premium) | `string`       | `C`                                      | no     |
| redis_sku_name                        | The SKU of Redis to use. Possible values are Basic, Standard and Premium                             | `string`       | `Standard`                               | no     |

### Outputs
| Name | Description |
|------|-------------|
| azure_resource_group_name | The name of the resource group in which resources are created |
| azure_resource_group_location | The location of the resource group in which resources are created |
| aks_cluster_name | The name of the AKS cluster created |
| storage_bucket_name | azure storage bucket name |
| storage_account_name | name of azure storage account |
| storage_access_key | access key which is used to access to storage bucket |
| storage_account_endpoint | The endpoint of azure storage account |
| db_instance_address | fully qualified domain name of the postgres server |
| db_instance_name | id the postgresql server |
| db_instance_username | username of the master database |
| db_master_password | password of the master database |
| coverity_cache_bucket_name | The name of the coverity cache bucket |
| redis_host | The host address of the Redis instance |
| redis_port | The port number of the Redis instance |
| redis_password | The password of the Redis instance |


## Prerequisites

### Install or upgrade Terraform

Install terraform, or update if already installed:

```bash
$ brew install terraform

$ brew upgrade terraform
```

### Clone this repository

```bash
$ git clone git@github.com:Synopsys-SIG-RnD/terraform-cnc-modules.git
$ cd terraform-cnc-modules/2022.6/azure
```

Azure Cli needs to be installed to work with azure terraform automation modules. please refer https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
### Get set up with azure

```bash
$ az login
```

### Create global resources
```bash
$ cd terraform-cnc-modules/azure/global-resources
export TF_VAR_subscription_id ="YOUR AZURE SUBSCRIPTION ID" # you can find the subscription id in azure portal or in the "id" value of the json output when you run "az login" command
$ vi terraform.tfvars.example # modify/add input values per your requirements and save it
$ terraform init
$ terraform plan -var-file="terraform.tfvars.example"
$ terraform apply --auto-approve -var-file="terraform.tfvars.example"
```
you can use sample values in 1.auto.tfvars as reference.

### Create environment resources
```bash
$ cd terraform-cnc-modules/azure/environment
TF_VAR_subscription_id ="YOUR AZURE SUBSCRIPTION ID"
$ vi terraform.tfvars.example # modify/add input values per your requirements and save it
$ terraform init
$ terraform plan -var-file="terraform.tfvars.example"
$ terraform apply --auto-approve -var-file="terraform.tfvars.example"
```

while destroying, please destroy the environment resources first and then destroy the global resources.

while destroying environment resources, if you experience network or any connection issue, then sometimes destroying the resources will fail. in such cases, just retry the terraform destroy command.
