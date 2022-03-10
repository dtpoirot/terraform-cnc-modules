# Coverity on GCP: reference implementation

This Terraform code creates GCP resources using two separate modules:

- [global-resources](./global-resources): VPC network, subnetwork and GKE cluster
- [environment](./environment): CloudSQL instance, GCS bucket (if `scanfarm_enabled` is `true`), nginx-ingress-controller


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
$ cd terraform-cnc-modules/2022.3/gcp
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
