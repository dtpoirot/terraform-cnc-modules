# Coverity on AWS: reference implementation

Terraform creates the below AWS cloud resources by using the individual modules.
- [global-resources](./global-resources): This module will create VPC , SUBNETS ,EKS Cluster and deploy cluster-autoscaller .
- [environment](./environment): This module will create S3 bucket, RDS instance along with related security group rules and deploy nginx-ingress-controller in the existing cluster.

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

$ cd terraform-cnc-modules/2022.3/aws
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

### global resources creation
Here, terraform will create all the required resources from the scratch (set `scanfarm_enabled` flag value as true to create scanfarm resources).
```bash
$ vi terraform.tfvars.example # modify/add input values per your requirements and save it
$ terraform init
$ terraform plan -var-file="terraform.tfvars.example"
$ terraform apply --auto-approve -var-file="terraform.tfvars.example"
```


**Note:** If cluster-autoscaler is already deployed in your eks cluster, then set the respective flags to `false`

## Global Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws_access_key                        | AWS access key to create the resources                         | `string`                | n/a                                      | yes     |
| aws_secret_key                        | AWS secret key to create the resources                         | `string`                | n/a                                      | yes     |
| aws_region                            | AWS region to create the resources                             | `string`                | n/a                                      | yes     |
| tags                                  | AWS Tags to add to all resources created (wherever possible); see https://aws.amazon.com/answers/account-management/aws-tagging-strategies/   | `map(string)`               | `{'product': 'cnc', 'automation': 'dns', 'managedby': 'terraform'}` | no     |
| prefix                                | Prefix to use for objects that need to be created (only alphanumeric characters and hyphens allowed) `Note: hyphens will be removed from prefix for RDS, S3 and namespace resources`    | `string`                      | n/a        | yes     |
| vpc_id                                | ID of the existing VPC; if empty, then VPC will be created     | `string`                                 | `""`                                       | no      |
| vpc_cidr_block                        | CIDR block for the VPC                                         | `string`                                 | `"10.0.0.0/16"`                            | no      |
| cluster_name                          | Name of the existing EKS cluster; if empty, then EKS cluster will be created        | `string`                                                                               | `""`                                       | no      |
| map_users                             | Additional IAM users to add to the aws-auth configmap                               |  ```list(object({ userarn  = string username = string groups   = list(string) }))```   | `[]`                                       | no      |
| kubernetes_version                    | Kubernetes version of the EKS cluster                                               | `string`                                                                               | `"1.21"`                                   | no      |
| cluster_endpoint_public_access_cidrs  | List of CIDR blocks which can access the Amazon EKS public API server endpoint. `Note: by default its open to all, we recommend to set your org CIDR blocks`                    | `list(string)`                       | `['0.0.0.0/0']`                            | no      |
| deploy_autoscaler                     | Flag to enable/disable the cluster-autoscaler deployment in the eks cluster         | `bool`              | `true`                                     | no      |
| cluster_autoscaler_helm_chart_version | Version of the cluster-autoscaler helm chart                                        | `string`            | `"9.10.4"`                                 | no      |
| default_node_pool_instance_type       | Instance type of each node in a default node pool                                   | `string`            | `"m5d.2xlarge"`                            | no      |
| default_node_pool_ami_type            | Type of Amazon Machine Image (AMI) associated with the EKS Node Group               | `string`            | `"AL2_x86_64"`                             | no      |
| default_node_pool_disk_size           | Disk size in gb for each node in a default node pool                                | `number`            | `50`                                       | no      |
| default_node_pool_capacity_type       | Type of instance capacity to provision default node pool. Options are `ON_DEMAND` and `SPOT`              | `string`                  | `"ON_DEMAND"`              | no      |
| default_node_pool_min_size            | Min number of nodes in a default node pool                                                                | `number`                  | `3`                        | no      |
| default_node_pool_max_size            | Max number of nodes in a default node pool                                                                | `number`                  | `9`                        | no      |
| jobfarm_node_pool_instance_type       | Instance type of each node in a jobfarm node pool                                                         | `string`                  | `"m5d.2xlarge"`            | no      |
| jobfarm_node_pool_ami_type            | Type of Amazon Machine Image (AMI) associated with the EKS Node Group                                     | `string`                  | `"AL2_x86_64"`             | no      |
| jobfarm_node_pool_disk_size           | Disk size in gb for each node in a jobfarm node pool                                                      | `number`                  | `100`                      | no      |
| jobfarm_node_pool_capacity_type       | Type of instance capacity to provision jobfarm node pool. Options are `ON_DEMAND` and `SPOT`              | `string`                  | `"SPOT"`                   | no      |
| jobfarm_node_pool_min_size            | Min number of nodes in a jobfarm node pool                                                                | `number`                  | `0`                        | no      |
| jobfarm_node_pool_max_size            | Max number of nodes in a jobfarm node pool                                                                | `number`                  | `50`                       | no      |

## Global resource outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| vpc_cidr_block | The CIDR block of the VPC |
| vpc_public_subnets | List of IDs of public subnets |
| vpc_private_subnets | List of IDs of private subnets |
| vpc_nat_public_ips | List of public Elastic IPs created for AWS NAT Gateway |
| cluster_name | The name of the EKS cluster |
| cluster_region | The AWS region this EKS cluster resides in |
<!-- ### Scenario-4: Infrastructure creation with existing VPC, EKS cluster and S3 bucket
Here, terraform will create the RDS instance.
```bash
$ export TF_VAR_prefix="cnc"
$ export TF_VAR_vpc_id="vpc-07dc99f9a6682xxxx"
$ export TF_VAR_cluster_name="cnc-cluster"
$ export TF_VAR_bucket_name="cnc-uploads-bucket"
$ terraform init
$ terraform plan
$ terraform apply --auto-approve
``` -->

<!-- ### Scenario-5: Infrastructure creation with existing VPC, EKS cluster, S3 bucket and RDS instance
Here, terraform will create the namespace and two kubernetes secrets (`cnc-db-credentials`, `cnc-s3-credentials`) in it.
```bash
$ export TF_VAR_prefix="cnc"
$ export TF_VAR_vpc_id="vpc-07dc99f9a6682xxxx"
$ export TF_VAR_cluster_name="cnc-cluster"
$ export TF_VAR_bucket_name="cnc-uploads-bucket"
$ export TF_VAR_db_name="cnc-postgres"
$ export TF_VAR_db_password="<random_password>"
$ terraform init
$ terraform plan
$ terraform apply --auto-approve
```
**Note:** As terraform can't read the db password from existing db, You MUST pass `db_password` variable value along with `db_name` -->
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
- We recommend using your organization's CIDR ip ranges to set `cluster_endpoint_public_access_cidrs` value 
- To create scanfarm resources, set `scanfarm_enabled` to `true`

### environment resources creation
Here, terraform will create all the required resources from the scratch (set `scanfarm_enabled` flag value as true to create scanfarm resources).
```bash
$ vi terraform.tfvars.example # modify/add input values per your requirements and save it
$ terraform init
$ terraform plan -var-file="terraform.tfvars.example"
$ terraform apply --auto-approve -var-file="terraform.tfvars.example"
```

**Note:** If nginx-ingress-controller is already deployed in your eks cluster, then set the respective flags to `false`

## Environment Inputs
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws_access_key                        | AWS access key to create the resources                         | `string`                | n/a                                      | yes     |
| aws_secret_key                        | AWS secret key to create the resources                         | `string`                | n/a                                      | yes     |
| aws_region                            | AWS region to create the resources                             | `string`                | n/a                                      | yes     |
| tags                                  | AWS Tags to add to all resources created (wherever possible); see https://aws.amazon.com/answers/account-management/aws-tagging-strategies/   | `map(string)`               | `{'product': 'cnc', 'automation': 'dns', 'managedby': 'terraform'}` | no     |
| prefix                                | Prefix to use for objects that need to be created (only alphanumeric characters and hyphens allowed) `Note: hyphens will be removed from prefix for RDS, S3 and namespace resources`    | `string`                      | n/a        | yes     |
| bucket_name                           | Name of the S3 bucket; if empty, then S3 bucket will be created                                           | `string`                  | `""`                       | no      |
| db_name                               | Name of the RDS instance; if empty, then RDS instance will be created                                     | `string`                  | `""`                       | no      |
| db_postgres_version                   | Postgres version of the RDS instance                                                                      | `string`                  | `"14"`                    | no      |
| db_username                           | Username for the master DB user. `Note: Do NOT use 'user' as the value`                                   | `string`                  | `"postgres"`               | no      |
| db_password                           | Password for the master DB user; If empty, then random password will be set by default. `Note: This will be stored in the state file` | `string`       | `""`      | no      |
| db_public_access                      | Bool to control if instance is publicly accessible                                                        | `bool`                    | `false`                    | no      |
| db_instance_class                     | Instance type of the RDS instance                                                                         | `string`                  | `"db.t3.small"`            | no      |
| db_size_in_gb                         | Storage size in gb of the RDS instance                                                                    | `number`                  | `10`                       | no      |
| db_port                               | Port number on which the DB accepts connections                                                           | `number`                  | `5432`                     | no      |
| deploy_ingress_controller             | Flag to enable/disable the nginx-ingress-controller deployment in the eks cluster   | `bool`              | `true`                                     | no      |
| ingress_controller_helm_chart_version | Version of the nginx-ingress-controller helm chart                                  | `string`            | `"3.35.0"`                                 | no      |

<!-- | create_db_secret                      | Flag to enable/disable the `cnc-db-credentials` secret creation in the eks cluster                        | `bool`                    | `true`                     | no      |
| create_s3_secret                      | Flag to enable/disable the `cnc-s3-credentials` secret creation in the eks cluster                        | `bool`                    | `true`                     | no      | -->
| vpc_id                                | ID of the existing VPC; if empty, then VPC will be created     | `string`                                 | `""`                                       | no      |
| vpc_cidr_block                        | CIDR block for the VPC                                         | `string`                                 | `"10.0.0.0/16"`                            | no      |
| cluster_name                          | Name of the existing EKS cluster from the global output        | `string`                                                                               | `""`                                       | no      |
| cluster_endpoint_public_access_cidrs  | List of CIDR blocks which can access the Amazon EKS public API server endpoint.it attaches to the ingress controller sources ranges. `Note: by default its open to all, we recommend to set your org CIDR blocks`                    | `list(string)`                       | `['0.0.0.0/0']`                            | no      |
| vpc_nat_public_ips | List of public Elastic IPs created for AWS NAT Gateway , you will get it from global output| list(string) | `[""]`   | yes |
| vpc_private_subnets | List of IDs of private subnets from the global output | list(string) | `[""]`   | yes 

## Envronment resources Outputs
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
<!-- | namespace | The namespace in the EKS cluster where secrets resides in | -->

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
```

