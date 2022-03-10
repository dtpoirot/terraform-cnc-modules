# Environment resources

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| gcp_project                           | GCP project id to create the resources                                                               | `string`       | n/a                                      | yes      |
| gcp_region                            | GCP region to create the resources                                                                   | `string`       | n/a                                       | yes      |
| tags                                  | GCP Tags to add to all resources created (wherever possible)                                         | `map("string")` | `{'product': 'cnc', 'automation': 'dns', 'managedby': 'terraform'}` | no       |
| prefix                                | Prefix to use for objects that need to be created. This must be unique                                                    | `string`       | n/a                                       | yes      |
| gcp_network_self_link                 | Name of the existing VPC network self link. Format looks like: https://www.googleapis.com/compute/v1/projects/{gcp_project}/global/networks/{vpc_name} | `string`       | n/a                                       | yes      |
| gcp_cluster_name                      | Name of the existing GKE cluster to deploy ingress / create secrets                         | `string`       | n/a                                       | yes      |
| bucket_name                           | Name of the gcs bucket; if empty, then gcs bucket will be created                                    | `string`       | `""`                                     | no       |
| bucket_region                         | Region of the gcs bucket                                                                             | `string`       | `US`                                     | no       |
| db_name                               | Name of the CloudSQL instance; if empty, then CloudSQL instance will be created                      | `string`       | `""`                                     | no       |
| db_tier                               | The machine type to use for CloudSQL instance                                                        | `string`       | `db-custom-2-4096`                       | no       |
| db_version                            | Postgres database version                                                                            | `string`       | `POSTGRES_14`                           | no       |
| db_availability                       | The availability type of the CloudSQL instance                                                       | `string`       | `ZONAL`                                  | no       |
| db_size_in_gb                         | Storage size in gb of the CloudSQL instance                                                          | `number`       | `10`                                     | no       |
| database_flags                        | database_flags for CloudSQL instance                                                                 | `map("any")`   | `{}`                                     | no       |
| db_username                           | Username for the master DB user. Note: Do NOT use 'user' as the value                                | `string`       | `postgres`                               | no       |
| db_password                           | Password for the master DB user; If empty, then random password will be set by default. Note: This will be stored in the state file | `string`       | `""`                                     | no       |
| db_ipv4_enabled                       | Whether this Cloud SQL instance should be assigned a public IPV4 address. Either ipv4_enabled must be enabled or a private_network must be configured. | `bool`         | `false`                                  | no       |
| db_require_ssl                        | Whether SSL connections over IP are enforced or not; if this is true, then certs will be stored in additional k8s secret(`cnc-db-ssl-cert`) | `bool`         | `false`                                  | no       |
| maintenance_window_day                | The maintenance window is specified in UTC time                                                      | `number`       | `7`                                      | no       |
| maintenance_window_hour               | The maintenance window is specified in UTC time                                                      | `number`       | `9`                                      | no       |
| deploy_ingress_controller             | Flag to enable/disable the nginx-ingress-controller deployment in the GKE cluster                    | `bool`         | `true`                                   | no       |
| ingress_namespace                     | Namespace in which ingress controller should be deployed. If empty, then ingress-controller will be created | `string`       | `""`                                     | no       |
| ingress_controller_helm_chart_version | Version of the nginx-ingress-controller helm chart                                                   | `string`       | `3.35.0`                                 | no       |
| ingress_white_list_ip_ranges          | List of source ip ranges for load balancer whitelisting; we recommend you to pass the list of your organization source IPs. Note: You must add NAT IP of your existing VPC or `gcp_nat_public_ip` output value from global module to this list | `list("string")` | `['0.0.0.0/0']`                          | no       |
| ingress_settings                      | Additional settings which will be passed to the Helm chart values, see https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx | `map("string")` | `{}`                                     | no       |
| app_namespace                         | Namespace of existing cluster in which secrets can be created; if empty, then namespace will be created with prefix value | `string`       | `""`                                     | no       |
<!-- | create_db_secret                      | Flag to enable/disable the 'cnc-db-credentials' secret creation in the eks cluster                   | `bool`         | `true`                                   | no       |
| create_gcs_secret                     | Flag to enable/disable the 'cnc-gcs-credentials' secret creation in the gke cluster                  | `bool`         | `true`                                   | no       |
| db_host                               | Host addr of the CloudSQL instance                                                                   | `string`       | `""`                                     | no       |
| db_port                               | Port number of CloudSQL instance                                                                 | `number`       | `5432`                                   | no       | -->

## Outputs
| Name | Description |
|------|-------------|
| gcp_project_id | The ID of the GCP project |
| gcp_cluster_name | The name of the GKE cluster |
| gcp_cluster_region | The GCP region this GKE cluster resides in |
| gcs_bucket_name | The name of the GCS bucket |
| gcs_bucket_region | The region where GCS bucket resides in |
| db_instance_name | The name of the CloudSQL instance |
| db_instance_address | The address of the CloudSQL instance |
| db_instance_username | The master username for the CloudSQL instance |
| db_master_password | The master password for the CloudSQL instance |
<!-- | namespace | The namespace in the GKE cluster where secrets resides in | -->