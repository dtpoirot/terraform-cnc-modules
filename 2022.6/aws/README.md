# Coverity on AWS: reference implementation

Terraform creates the below AWS cloud resources by using the individual modules.
- [global-resources](./global-resources): This module will create VPC, SUBNETS, EKS Cluster and deploy cluster-autoscaller.
- [environment](./environment): This module will create S3 bucket, RDS instance along with related security group rules and deploy nginx-ingress-controller in the existing cluster.

## Global resources
### Inputs

| Name                                  | Description                                                                              | Type                                     | Default                                  | Required |
|---------------------------------------|------------------------------------------------------------------------------------------|------------------------------------------|------------------------------------------|--------|
| aws_access_key                        | AWS access key to create the resources                                                   | `string`                                 | ``                                       | yes    |
| aws_secret_key                        | AWS secret key to create the resources                                                   | `string`                                 | ``                                       | yes    |
| aws_region                            | AWS region to create the resources                                                       | `string`                                 | ``                                       | yes    |
| tags                                  | AWS Tags to add to all resources created (wherever possible)                             | `map("string")`                          | `{'product': 'cnc', 'automation': 'dns', 'managedby': 'terraform'}` | no     |
| prefix                                | Prefix to use for objects that need to be created                                        | `string`                                 | ``                                       | yes    |
| create_vpc                            | controls if VPC should be created                                                        | `bool`                                   | `true`                                   | no     |
| vpc_cidr_block                        | CIDR block for the VPC                                                                   | `string`                                 | `10.0.0.0/16`                            | no     |
| vpc_id                                | ID of the existing VPC                                                                   | `string`                                 | `""`                                     | no     |
| create_eks                            | controls if EKS should be created                                                        | `bool`                                   | `true`                                   | no     |
| scanfarm_enabled                      | Whether scanfarm resources have to be created or not; Defaults to false (BETA)           | `bool`                                   | `false`                                  | no     |
| cluster_name                          | Name of the existing EKS cluster; if empty, then EKS cluster will be created             | `string`                                 | `""`                                     | no     |
| map_users                             | Additional IAM users to add to the aws-auth configmap                                    | `list("object({userarn:"string",username:"string",groups:"list("string")"})")` | `[]`                                     | no     |
| kubernetes_version                    | Kubernetes version of the EKS cluster                                                    | `string`                                 | `1.21`                                   | no     |
| cluster_endpoint_public_access_cidrs  | List of CIDR blocks which can access the Amazon EKS public API server endpoint           | `list("string")`                         | `['0.0.0.0/0']`                          | no     |
| cluster_create_timeout                | Timeout value when creating the EKS cluster.                                             | `string`                                 | `60m`                                    | no     |
| deploy_autoscaler                     | Flag to enable/disable the cluster-autoscaler deployment in the eks cluster              | `bool`                                   | `true`                                   | no     |
| cluster_autoscaler_helm_chart_version | Version of the cluster-autoscaler helm chart                                             | `string`                                 | `9.10.4`                                 | no     |
| default_node_pool_instance_type       | Instance type of each node in a default node pool                                        | `string`                                 | `m5d.2xlarge`                            | no     |
| default_node_pool_ami_type            | Type of Amazon Machine Image (AMI) associated with the EKS Node Group                    | `string`                                 | `AL2_x86_64`                             | no     |
| default_node_pool_disk_size           | Disk size in gb for each node in a default node pool                                     | `number`                                 | `50`                                     | no     |
| default_node_pool_capacity_type       | Type of instance capacity to provision default node pool. Options are ON_DEMAND and SPOT | `string`                                 | `ON_DEMAND`                              | no     |
| default_node_pool_min_size            | Min number of nodes in a default node pool                                               | `number`                                 | `3`                                      | no     |
| default_node_pool_max_size            | Max number of nodes in a default node pool                                               | `number`                                 | `9`                                      | no     |
| jobfarm_node_pool_instance_type       | Instance type of each node in a jobfarm node pool                                        | `string`                                 | `m5d.2xlarge`                            | no     |
| jobfarm_node_pool_ami_type            | Type of Amazon Machine Image (AMI) associated with the EKS Node Group                    | `string`                                 | `AL2_x86_64`                             | no     |
| jobfarm_node_pool_disk_size           | Disk size in gb for each node in a jobfarm node pool                                     | `number`                                 | `100`                                    | no     |
| jobfarm_node_pool_capacity_type       | Type of instance capacity to provision jobfarm node pool. Options are ON_DEMAND and SPOT | `string`                                 | `SPOT`                                   | no     |
| jobfarm_node_pool_min_size            | Min number of nodes in a jobfarm node pool                                               | `number`                                 | `0`                                      | no     |
| jobfarm_node_pool_max_size            | Max number of nodes in a jobfarm node pool                                               | `number`                                 | `50`                                     | no     |
| jobfarm_node_pool_taints              | Taints for the jobfarm node pool                                                         | `list("any")`                            | `[{'key': 'NodeType', 'value': 'ScannerNode', 'effect': 'NO_SCHEDULE'}]` | no     |

### Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| vpc_cidr_block | The CIDR block of the VPC |
| vpc_public_subnets | List of IDs of public subnets |
| vpc_private_subnets | List of IDs of private subnets |
| vpc_nat_public_ips | List of public Elastic IPs created for AWS NAT Gateway |
| cluster_name | The name of the EKS cluster |
| cluster_region | The AWS region this EKS cluster resides in |

## Environment resources
### Inputs
| Name                                  | Description                                                                                          | Type           | Default                                  | Required |
|---------------------------------------|------------------------------------------------------------------------------------------------------|----------------|------------------------------------------|--------|
| aws_access_key                        | AWS access key to create the resources                                                               | `string`       | ``                                       | yes    |
| aws_secret_key                        | AWS secret key to create the resources                                                               | `string`       | ``                                       | yes    |
| aws_region                            | AWS region to create the resources                                                                   | `string`       | ``                                       | yes    |
| tags                                  | AWS Tags to add to all resources created (wherever possible)                                         | `map("string")` | `{'product': 'cnc', 'automation': 'dns', 'managedby': 'terraform'}` | no     |
| prefix                                | Prefix to use for objects that need to be created                                                    | `string`       | ``                                       | yes    |
| cluster_name                          | Name of the existing EKS cluster; if empty, then EKS cluster will be created                         | `string`       | `""`                                     | no     |
| bucket_name                           | Name of the S3 bucket; if empty, then S3 bucket will be created                                      | `string`       | `""`                                     | no     |
| create_bucket                         | controls if s3 bucket should be created                                                              | `bool`         | `true`                                   | no     |
| coverity_cache_age                    | No.of days for expiration of S3 objects in coverity-cache-bucket. Should be atleast 3 days           | `number`       | `15`                                     | no     |
| create_db_instance                    | controls if RDS instance should be created                                                           | `bool`         | `true`                                   | no     |
| db_name                               | Name of the RDS instance; if empty, then RDS instance will be created                                | `string`       | `""`                                     | no     |
| db_postgres_version                   | Postgres version of the RDS instance                                                                 | `string`       | `14`                                     | no     |
| db_username                           | Username for the master DB user. Note: Do NOT use 'user' as the value                                | `string`       | `postgres`                               | no     |
| db_password                           | Password for the master DB user; If empty, then random password will be set by default. Note: This will be stored in the state file | `string`       | `""`                                     | no     |
| db_vpc_cidr_blocks                    | CIDR Block of EKS cluster                                                                            | `list("any")`  | `['10.0.0.0/16']`                        | no     |
| db_public_access                      | Bool to control if instance is publicly accessible                                                   | `bool`         | `false`                                  | no     |
| db_instance_class                     | Instance type of the RDS instance                                                                    | `string`       | `db.t3.small`                            | no     |
| db_size_in_gb                         | Storage size in gb of the RDS instance                                                               | `number`       | `10`                                     | no     |
| db_port                               | Port number on which the DB accepts connections                                                      | `number`       | `5432`                                   | no     |
| vpc_private_subnets                   | list of private subnets created within the vpc                                                       | `list("string")` | ``                                       | yes    |
| vpc_cidr_block                        | vpc cidr block ,in which vpc is created                                                              | `string`       | `10.0.0.0/16`                            | no     |
| vpc_id                                | id of the vpc created                                                                                | `string`       | ``                                       | yes    |
| scanfarm_enabled                      | it will enable the scanform components                                                               | `bool`         | `false`                                  | no     |
| vpc_nat_public_ips                    | nat public ip to create the ingress controller                                                       | `list("string")` | `['']`                                   | no     |
| cluster_endpoint_public_access_cidrs  | List of CIDR blocks which can access the Amazon EKS public API server endpoint                       | `list("string")` | `['0.0.0.0/0']`                          | no     |
| deploy_ingress_controller             | Flag to enable/disable the nginx-ingress-controller deployment in the eks cluster                    | `bool`         | `true`                                   | no     |
| ingress_controller_helm_chart_version | Version of the nginx-ingress-controller helm chart                                                   | `string`       | `3.35.0`                                 | no     |
| redis_cluster_size                    | Number of nodes in cluster                                                                           | `number`       | `1`                                      | no     |
| redis_engine_version                  | Redis engine version                                                                                 | `string`       | `5.0.6`                                  | no     |
| redis_family                          | Redis family                                                                                         | `string`       | `redis5.0`                               | no     |
| redis_instance_type                   | Elastic cache instance type. See https://aws.amazon.com/elasticache/pricing/#On-Demand_Nodes for other instance types | `string`       | `cache.t3.small`                         | no     |
| redis_configs                         | The Redis configuration parameters.                                                                  | `map("any")`   | `{}`                                     | no     |

### Outputs
| Name | Description |
|------|-------------|
| cluster_name | The name of the EKS cluster |
| cluster_region | The AWS region this EKS cluster resides in |
| s3_bucket_name | The name of the S3 bucket |
| s3_bucket_region | The AWS region this S3 bucket resides in |
| db_instance_name | The name of the RDS instance |
| db_instance_address | The address of the RDS instance |
| db_instance_port |The database port of the RDS instance |
| db_instance_username | The master username for the RDS instance |
| db_master_password | The master password for the RDS instance |
| db_subnet_group_id | The subnet group name of the RDS instance |
| coverity_cache_bucket_name | The name of the coverity cache bucket |
| redis_host | The host address of the Redis instance |
| redis_port | The port number of the Redis instance |
| redis_password | The password of the Redis instance |
<!-- | namespace | The namespace in the EKS cluster where secrets resides in | -->

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

$ cd terraform-cnc-modules/2022.6/aws
```

### Set up environment variables
```bash
$ export TF_VAR_aws_access_key="<aws_access_key>"
$ export TF_VAR_aws_secret_key="<aws_secret_key>"
$ export TF_VAR_aws_region="<aws_region>"
$ export TF_VAR_prefix="<unique_prefix_str>"
```

**Notes:**
- Use [these instructions](https://aws.amazon.com/premiumsupport/knowledge-center/create-access-key/) to get access and secret key from AWS.
- Terraform variable values can be passed in different ways. Please refer to [the Terraform docs](https://www.terraform.io/docs/language/values/variables.html#variable-definition-precedence) for alternatives
- We recommend using your organization's CIDR ip ranges to set `cluster_endpoint_public_access_cidrs` value and also set `map_users` appropriately
- To create scanfarm resources, set `scanfarm_enabled` to `true`

### Create global resources
Here, terraform will create all the required resources from the scratch (set `scanfarm_enabled` flag value as true to create scanfarm resources).

```bash
$ vi terraform.tfvars.example # modify/add input values per your requirements and save it
$ terraform init
$ terraform plan -var-file="terraform.tfvars.example"
$ terraform apply --auto-approve -var-file="terraform.tfvars.example"
```

**Note:** If cluster-autoscaler is already deployed in your eks cluster, then set the respective flags to `false`

### Create environment resources
Here, terraform will create all the required resources from the scratch (set `scanfarm_enabled` flag value as true to create scanfarm resources).

```bash
$ vi terraform.tfvars.example # modify/add input values per your requirements and save it
$ terraform init
$ terraform plan -var-file="terraform.tfvars.example"
$ terraform apply --auto-approve -var-file="terraform.tfvars.example"
```

**Note:** If nginx-ingress-controller is already deployed in your eks cluster, then set the respective flags to `false`

### After terraform setup: run the terraform output script

Run this [script](./get-tf-outputs.sh) to get the required values for the deployment.

```bash
export COVERITY_CLUSTER_NAME=???
export COVERITY_CLUSTER_REGION=???
export COVERITY_PGHOST=???.rds.amazonaws.com
export COVERITY_PGPORT=5432
export COVERITY_PGUSER=postgres
export COVERITY_PGPASSWORD=???
export COVERITY_S3_BUCKET_NAME=???
export COVERITY_S3_BUCKET_REGION=???
export COVERITY_CACHE_BUCKET_NAME=???
export COVERITY_REDIS_HOST=???
export COVERITY_REDIS_PORT=???
export COVERITY_REDIS_PASSWORD=???
```

