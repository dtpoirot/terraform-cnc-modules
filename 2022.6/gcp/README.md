# Coverity on GCP: reference implementation

This Terraform code creates GCP resources using two separate modules:

- [global-resources](./global-resources): VPC network, subnetwork and GKE cluster
- [environment](./environment): CloudSQL instance, GCS bucket (if `scanfarm_enabled` is `true`), nginx-ingress-controller


## Global resources
### Inputs
| Name                              | Description                                                                                          | Type                                     | Default                                  | Required |
|-----------------------------------|------------------------------------------------------------------------------------------------------|------------------------------------------|------------------------------------------|--------|
| gcp_project                       | GCP project id to create the resources                                                               | `string`                                 | ``                                       | yes    |
| gcp_region                        | GCP region to create the resources                                                                   | `string`                                 | ``                                       | yes    |
| tags                              | GCP Tags to add to all resources created (wherever possible)                                         | `map("string")`                          | `{'product': 'cnc', 'automation': 'dns', 'managedby': 'terraform'}` | no     |
| scanfarm_enabled                  | Whether scanfarm resources have to be created or not; Defaults to false (BETA)                       | `bool`                                   | `false`                                  | no     |
| prefix                            | Prefix to use for objects that need to be created. This must be unique                               | `string`                                 | ``                                       | yes    |
| vpc_name                          | Name of the existing VPC; if empty VPC will be created                                               | `string`                                 | `""`                                     | no     |
| vpc_cidr_block                    | CIDR block for the VPC subnet. Default: 10.0.0.0/16                                                  | `string`                                 | `10.0.0.0/16`                            | no     |
| vpc_secondary_range_pods          | Secondary subnet range in the VPC network for pods. Default: 172.16.0.0/16                           | `string`                                 | `172.16.0.0/16`                          | no     |
| vpc_secondary_range_services      | Secondary subnet range in the VPC network for services. Default: 192.168.0.0/19                      | `string`                                 | `192.168.0.0/19`                         | no     |
| subnet_private_access             | Enable private access for the subnet                                                                 | `bool`                                   | `true`                                   | no     |
| subnet_flow_logs                  | Enable vpc flow logs for the subnet                                                                  | `bool`                                   | `false`                                  | no     |
| subnet_flow_logs_interval         | subnet flow log interval                                                                             | `string`                                 | `INTERVAL_5_SEC`                         | no     |
| subnet_flow_logs_sampling         | subnet flow logs sampling                                                                            | `string`                                 | `1`                                      | no     |
| subnet_flow_logs_metadata         | Subnet flow logs type                                                                                | `string`                                 | `INCLUDE_ALL_METADATA`                   | no     |
| cloud_nat_logs_enabled            | Enable logging for the CloudNAT                                                                      | `bool`                                   | `false`                                  | no     |
| cloud_nat_logs_filter             | Log level for the CloudNAT                                                                           | `string`                                 | `ERRORS_ONLY`                            | no     |
| vpc_subnet_name                   | Existing VPC subnet name in which cluster has to be created                                          | `string`                                 | `""`                                     | no     |
| vpc_pod_range_name                | Existing VPC pod range name to create the cluster                                                    | `string`                                 | `""`                                     | no     |
| vpc_service_range_name            | Existing VPC service range name to create the cluster                                                | `string`                                 | `""`                                     | no     |
| master_ipv4_cidr_block            | Master ipv4 cidr range to create the cluster. Default: 192.168.254.0/28                              | `string`                                 | `192.168.254.0/28`                       | no     |
| kubernetes_version                | Kubernetes version of the GKE cluster                                                                | `string`                                 | `1.21.0`                                 | no     |
| release_channel                   | The release channel of this cluster. Accepted values are UNSPECIFIED, RAPID, REGULAR and STABLE. Defaults to UNSPECIFIED | `string`                                 | `UNSPECIFIED`                            | no     |
| master_authorized_networks_config | List of CIDR blocks which can access the Google GKE public API server endpoint. Default: open-to-all i.e 0.0.0.0/0 | `list("object({cidr_block:"string",display_name:"string"})")` | `[{'display_name': 'open-to-all', 'cidr_block': '0.0.0.0/0'}]` | no     |
| default_node_pool_machine_type    | Machine type of each node in a default node pool                                                     | `string`                                 | `n1-standard-8`                          | no     |
| default_node_pool_image_type      | Image type of each node in a default node pool                                                       | `string`                                 | `COS_CONTAINERD`                         | no     |
| default_node_pool_disk_size       | Disk size in gb for each node in a default node pool                                                 | `number`                                 | `50`                                     | no     |
| default_node_pool_disk_type       | Disk type of each node in a default node pool. Options are pd-standard and pd-ssd                    | `string`                                 | `pd-ssd`                                 | no     |
| default_node_pool_min_size        | Min number of nodes in a default node pool                                                           | `number`                                 | `1`                                      | no     |
| default_node_pool_max_size        | Max number of nodes in a default node pool                                                           | `number`                                 | `5`                                      | no     |
| jobfarm_node_pool_machine_type    | Machine type of each node in a jobfarm node pool                                                     | `string`                                 | `c2-standard-8`                          | no     |
| jobfarm_node_pool_image_type      | Image type to each node in a jobfarm node pool                                                       | `string`                                 | `COS_CONTAINERD`                         | no     |
| jobfarm_node_pool_disk_size       | Disk size in gb for each node in a jobfarm node pool                                                 | `number`                                 | `100`                                    | no     |
| jobfarm_node_pool_disk_type       | Disk type of each node in a jobfarm node pool. Options are pd-standard and pd-ssd                    | `string`                                 | `pd-ssd`                                 | no     |
| jobfarm_node_pool_min_size        | Min number of nodes in a jobfarm node pool                                                           | `number`                                 | `0`                                      | no     |
| jobfarm_node_pool_max_size        | Max number of nodes in a jobfarm node pool                                                           | `number`                                 | `50`                                     | no     |
| preemptible_jobfarm_nodes         | Flag to enable preemptible nodes in a jobfarm node pool                                              | `bool`                                   | `false`                                  | no     |
| jobfarm_node_pool_taints          | Taints for the jobfarm node pool                                                                     | `list("any")`                            | `[{'key': 'NodeType', 'value': 'ScannerNode', 'effect': 'NO_SCHEDULE'}]` | no     |
### Outputs
| Name | Description |
|------|-------------|
| gcp_network_name | The name of the VPC network |
| gcp_subnet_name | The name of the VPC subnet |
| gcp_nat_public_ip | The public IP created for GCP Cloud NAT Gateway; will be empty if VPC is created outside of this module |
| gcp_network_self_link | The URI of the VPC being created; will be empty if VPC is created outside of this module |
| gcp_cluster_name | The name of the GKE cluster |
| gcp_cluster_region | The GCP region this GKE cluster resides in |

## Environment resources
### Inputs
| Name                                  | Description                                                                                          | Type           | Default                                  | Required |
|---------------------------------------|------------------------------------------------------------------------------------------------------|----------------|------------------------------------------|--------|
| gcp_project                           | GCP project id to create the resources                                                               | `string`       | ``                                       | yes    |
| gcp_region                            | GCP region to create the resources                                                                   | `string`       | ``                                       | yes    |
| tags                                  | GCP Tags to add to all resources created (wherever possible)                                         | `map("string")` | `{'product': 'cnc', 'automation': 'dns', 'managedby': 'terraform'}` | no     |
| scanfarm_enabled                      | Whether scanfarm resources have to be created or not; Defaults to false                              | `bool`         | `false`                                  | no     |
| prefix                                | Prefix to use for objects that need to be created. This must be unique                               | `string`       | ``                                       | yes    |
| gcp_network_self_link                 | Name of the existing VPC network self link. Format looks like: https://www.googleapis.com/compute/v1/projects/{gcp_project}/global/networks/{vpc_name} | `string`       | ``                                       | yes    |
| gcp_cluster_name                      | Name of the existing GKE cluster to deploy ingress / create secrets                                  | `string`       | ``                                       | yes    |
| bucket_name                           | Name of the gcs bucket; if empty, then gcs bucket will be created                                    | `string`       | `""`                                     | no     |
| bucket_region                         | Region of the gcs bucket                                                                             | `string`       | `US`                                     | no     |
| coverity_cache_age                    | No.of days for expiration of gcs objects in coverity-cache-bucket. Should be atleast 3 days          | `number`       | `15`                                     | no     |
| db_name                               | Name of the CloudSQL instance; if empty, then CloudSQL instance will be created                      | `string`       | `""`                                     | no     |
| db_tier                               | The machine type to use for CloudSQL instance                                                        | `string`       | `db-custom-2-4096`                       | no     |
| db_version                            | Postgres database version                                                                            | `string`       | `POSTGRES_14`                            | no     |
| db_availability                       | The availability type of the CloudSQL instance                                                       | `string`       | `ZONAL`                                  | no     |
| db_size_in_gb                         | Storage size in gb of the CloudSQL instance                                                          | `number`       | `10`                                     | no     |
| database_flags                        | database_flags for CloudSQL instance                                                                 | `map("any")`   | `{}`                                     | no     |
| db_username                           | Username for the master DB user. Note: Do NOT use 'user' as the value                                | `string`       | `postgres`                               | no     |
| db_password                           | Password for the master DB user; If empty, then random password will be set by default. Note: This will be stored in the state file | `string`       | `""`                                     | no     |
| db_ipv4_enabled                       | Whether this Cloud SQL instance should be assigned a public IPV4 address. Either ipv4_enabled must be enabled or a private_network must be configured. | `bool`         | `false`                                  | no     |
| db_require_ssl                        | Whether SSL connections over IP are enforced or not;                                                 | `bool`         | `false`                                  | no     |
| maintenance_window_day                | The maintenance window is specified in UTC time                                                      | `number`       | `7`                                      | no     |
| maintenance_window_hour               | The maintenance window is specified in UTC time                                                      | `number`       | `9`                                      | no     |
| deploy_ingress_controller             | Flag to enable/disable the nginx-ingress-controller deployment in the GKE cluster                    | `bool`         | `true`                                   | no     |
| ingress_namespace                     | Namespace in which ingress controller should be deployed. If empty, then ingress-controller will be created | `string`       | `""`                                     | no     |
| ingress_controller_helm_chart_version | Version of the nginx-ingress-controller helm chart                                                   | `string`       | `3.35.0`                                 | no     |
| ingress_white_list_ip_ranges          | List of source ip ranges for load balancer whitelisting; we recommend you to pass the list of your organization source IPs. Note: You must add NAT IP of your existing VPC or `gcp_nat_public_ip` output value from global module to this list | `list("string")` | `['0.0.0.0/0']`                          | no     |
| ingress_settings                      | Additional settings which will be passed to the Helm chart values, see https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx | `map("string")` | `{}`                                     | no     |
| app_namespace                         | Namespace of existing cluster in which secrets can be created; if empty, then namespace will be created with prefix value | `string`       | `""`                                     | no     |
| redis_version                         | Redis instance version                                                                               | `string`       | `REDIS_5_0`                              | no     |
| redis_tier                            | The service tier of the redis instance. Possible values are BASIC and STANDARD_HA                    | `string`       | `STANDARD_HA`                            | no     |
| redis_memory_size_gb                  | Redis memory size in GiB                                                                             | `number`       | `2`                                      | no     |
| redis_configs                         | The Redis configuration parameters. See [more details](https://cloud.google.com/memorystore/docs/redis/reference/rest/v1/projects.locations.instances#Instance.FIELDS.redis_configs) | `map("any")`   | `{}`                                     | no     |

### Outputs
| Name | Description |
|------|-------------|
| gcp_project_id | The ID of the GCP project |
| gcp_cluster_name | The name of the GKE cluster |
| gcp_cluster_region | The GCP region this GKE cluster resides in |
| gcs_bucket_name | The name of the GCS bucket |
| gcs_bucket_region | The region where GCS bucket resides in |
| gcs_service_account | The service account to access the GCS bucket |
| db_instance_name | The name of the CloudSQL instance |
| db_instance_address | The address of the CloudSQL instance |
| db_instance_username | The master username for the CloudSQL instance |
| db_master_password | The master password for the CloudSQL instance |
| coverity_cache_bucket_name | The name of the coverity cache bucket |
| redis_host | The host ip of the Redis instance |
| redis_port | The port number of the Redis instance |
| redis_server_ca_cert | The server ca cert of the Redis instance |
<!-- | namespace | The namespace in the GKE cluster where secrets resides in | -->

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
$ cd terraform-cnc-modules/2022.6/gcp
```

### Notes

- You must have project Admin access (should be able to create IAM roles and service accounts) to create [environment](./gcp/environment) resources
- Terraform variable values can be passed in different ways. Please refer to [the Terraform docs](https://www.terraform.io/docs/language/values/variables.html#variable-definition-precedence) for alternatives
- We recommend using your organization's CIDR ip ranges to set `master_authorized_networks_config` and `ingress_white_list_ip_ranges` appropriately
- To create scanfarm resources in both global and environment folders, set `scanfarm_enabled` to `true`

## Create infrastructure resources
Let's create our Terraform resources!  This guide assumes you have no pre-existing resources.

You can modify the `terraform.tfvars.example` file in each module per your use case.

### Get set up with gcloud

```bash
$ gcloud auth application-default login
```

### Create global resources

```bash
$ cd terraform-cnc-modules/gcp/global-resources

 # modify/add input values per your requirements and save it
$ vi terraform.tfvars.example

$ terraform init
$ terraform plan -var-file="terraform.tfvars.example"
$ terraform apply --auto-approve -var-file="terraform.tfvars.example"
```

### Create environment resources

```bash
$ cd terraform-cnc-modules/gcp/environment

# modify/add input values using output from the global resources module
$ vi terraform.tfvars.example

$ terraform init
$ terraform plan -var-file="terraform.tfvars.example"
$ terraform apply --auto-approve -var-file="terraform.tfvars.example"
```

## Remove infrastructure resources

We'll remove resources in the opposite order!

**Note:** Due to weird behavior of terraform, by default the cloudsql instance is deleted before deleting the google_sql_user in it.
To avoid this problem, we remove the `google_sql_user` resource from the terraform state file manually.

### Remove environment resources

```bash
$ cd terraform-cnc-modules/gcp/environment

$ terraform state list | grep google_sql_user | xargs -I fl terraform state rm fl

$ terraform destroy --auto-approve -var-file="terraform.tfvars.example"
```

### Remove global resources

```bash
$ cd terraform-cnc-modules/gcp/global-resources

$ terraform destroy --auto-approve -var-file="terraform.tfvars.example"
```
