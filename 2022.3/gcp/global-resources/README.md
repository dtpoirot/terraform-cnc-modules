# Global resources

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| gcp_project                       | GCP project id to create the resources                                                               | `string`                                   | n/a                                        | yes      |
| gcp_region                        | GCP region to create the resources                                                                   | `string`                                   | n/a                                        | yes      |
| tags                              | GCP Tags to add to all resources created (wherever possible)                                         | `map("string")`                            | `{'product': 'cnc', 'automation': 'dns', 'managedby': 'terraform'}` | no       |
| prefix                            | Prefix to use for objects that need to be created. This must be unique                               | `string`                                   | n/a                                        | yes      |
| vpc_name                          | Name of the existing VPC; if empty VPC will be created                                               | `string`                                   | `""`                                       | no       |
| vpc_cidr_block                    | CIDR block for the VPC subnet. Default: 10.0.0.0/16                                                  | `string`                                   | `10.0.0.0/16 `                             | no       |
| vpc_secondary_range_pods          | Secondary subnet range in the VPC network for pods. Default: 172.16.0.0/16                           | `string`                                   | `172.16.0.0/16`                            | no       |
| vpc_secondary_range_services      | Secondary subnet range in the VPC network for services. Default: 192.168.0.0/19                      | `string`                                   | `192.168.0.0/19`                           | no       |
| subnet_private_access             | Enable private access for the subnet                                                                 | `bool`                                     | `true`                                     | no       |
| subnet_flow_logs                  | Enable vpc flow logs for the subnet                                                                  | `bool`                                     | `false`                                    | no       |
| subnet_flow_logs_interval         | subnet flow log interval                                                                             | `string`                                   | `INTERVAL_5_SEC`                           | no       |
| subnet_flow_logs_sampling         | subnet flow logs sampling                                                                            | `string`                                   | `1`                                        | no       |
| subnet_flow_logs_metadata         | Subnet flow logs type                                                                                | `string`                                   | `INCLUDE_ALL_METADATA`                     | no       |
| cloud_nat_logs_enabled            | Enable logging for the CloudNAT                                                                      | `bool`                                     | `false`                                    | no       |
| cloud_nat_logs_filter             | Log level for the CloudNAT                                                                           | `string`                                   | `ERRORS_ONLY`                              | no       |
| vpc_subnet_name                   | Existing VPC subnet name in which cluster has to be created                                          | `string`                                   | `""`                                       | no       |
| vpc_pod_range_name                | Existing VPC pod range name to create the cluster; keep it empty to  dynamically create                                                    | `string`                                   | `""`                                       | no       |
| vpc_service_range_name            | Existing VPC service range name to create the cluster; keep it empty to  dynamically create                                                | `string`                                   | `""`                                       | no       |
| master_ipv4_cidr_block            | Master ipv4 cidr range to create the cluster. Default: 192.168.254.0/28                              | `string`                                   | `192.168.254.0/28`                         | no       |
| kubernetes_version                | Kubernetes version of the GKE cluster                                                                | `string`                                   | `1.21.0`                                   | no       |
| release_channel                   | The release channel of this cluster. Accepted values are UNSPECIFIED, RAPID, REGULAR and STABLE. Defaults to UNSPECIFIED | `string`                                   | `UNSPECIFIED`                              | no       |
| master_authorized_networks_config | List of CIDR blocks which can access the Google GKE public API server endpoint. Default: open-to-all i.e 0.0.0.0/0 | `list("object({cidr_block:"string",display_name:"string"})")` | `[{'display_name': 'open-to-all', 'cidr_block': '0.0.0.0/0'}]` | no       |
| default_node_pool_machine_type    | Machine type of each node in a default node pool                                                     | `string`                                   | `n1-standard-8`                            | no       |
| default_node_pool_image_type      | Image type of each node in a default node pool                                                       | `string`                                   | `COS_CONTAINERD`                           | no       |
| default_node_pool_disk_size       | Disk size in gb for each node in a default node pool                                                 | `number`                                   | `50`                                       | no       |
| default_node_pool_disk_type       | Disk type of each node in a default node pool. Options are pd-standard and pd-ssd                    | `string`                                   | `pd-ssd`                                   | no       |
| default_node_pool_min_size        | Min number of nodes in a default node pool                                                           | `number`                                   | `1`                                        | no       |
| default_node_pool_max_size        | Max number of nodes in a default node pool                                                           | `number`                                   | `5`                                        | no       |
| jobfarm_node_pool_machine_type    | Machine type of each node in a jobfarm node pool                                                     | `string`                                   | `c2-standard-8`                            | no       |
| jobfarm_node_pool_image_type      | Image type to each node in a jobfarm node pool                                                       | `string`                                   | `COS_CONTAINERD`                           | no       |
| jobfarm_node_pool_disk_size       | Disk size in gb for each node in a jobfarm node pool                                                 | `number`                                   | `100`                                      | no       |
| jobfarm_node_pool_disk_type       | Disk type of each node in a jobfarm node pool. Options are pd-standard and pd-ssd                    | `string`                                   | `pd-ssd`                                   | no       |
| jobfarm_node_pool_min_size        | Min number of nodes in a jobfarm node pool                                                           | `number`                                   | `0`                                        | no       |
| jobfarm_node_pool_max_size        | Max number of nodes in a jobfarm node pool                                                           | `number`                                   | `50`                                       | no       |
| preemptible_jobfarm_nodes         | Flag to enable preemptible nodes in a jobfarm node pool                                              | `bool`                                     | `false`                                    | no       |
| jobfarm_node_pool_taints          | Taints for the jobfarm node pool                                                                     | `list("any")`                              | `[{'key': 'NodeType', 'value': 'ScannerNode', 'effect': 'NO_SCHEDULE'}]` | no       |

## Outputs
| Name | Description |
|------|-------------|
| gcp_network_name | The name of the VPC network |
| gcp_subnet_name | The name of the VPC subnet |
| gcp_nat_public_ip | The public IP created for GCP Cloud NAT Gateway; will be empty if VPC is created outside of this module |
| gcp_network_self_link | The URI of the VPC being created; will be empty if VPC is created outside of this module |
| gcp_cluster_name | The name of the GKE cluster |
| gcp_cluster_region | The GCP region this GKE cluster resides in |