## AWS provider configuration
variable "aws_access_key" {
  type        = string
  description = "AWS access key to create the resources"
  sensitive   = true
}

variable "aws_secret_key" {
  type        = string
  description = "AWS secret key to create the resources"
  sensitive   = true
}

variable "aws_region" {
  type        = string
  description = "AWS region to create the resources"
}

## Common configuration
variable "tags" {
  type        = map(string)
  description = "AWS Tags to add to all resources created (wherever possible)"
  default = {
    product    = "cnc"
    automation = "dns"
    managedby  = "terraform"
  }
}

variable "prefix" {
  type        = string
  description = "Prefix to use for objects that need to be created"
}

variable "cluster_name" {
  type        = string
  description = "Name of the existing EKS cluster; if empty, then EKS cluster will be created"
  default     = ""
}

## S3 configuration
variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket; if empty, then S3 bucket will be created"
  default     = ""
}

variable "create_bucket" {
  type        = bool
  description = "controls if s3 bucket should be created"
  default     = true
}

# variable "expire_after" {
#   type        = string
#   description = "No.of days for expiration of S3 objects"
#   default     = "30"
# }
## RDS configuration
variable "create_db_instance" {
  type        = bool
  description = "controls if RDS instance should be created"
  default     = true
}

variable "db_name" {
  type        = string
  description = "Name of the RDS instance; if empty, then RDS instance will be created"
  default     = ""
}

variable "db_postgres_version" {
  type        = string
  description = "Postgres version of the RDS instance"
  default     = "14"
}

# NOTE: Do NOT use 'user' as the value for 'username' as it throws:
# "Error creating DB Instance: InvalidParameterValue: MasterUsername
# user cannot be used as it is a reserved word used by the engine"
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

variable "db_vpc_cidr_blocks" {
  type        = list(any)
  description = "CIDR Block of EKS cluster"
  default     = ["10.0.0.0/16"]
}

variable "db_public_access" {
  type        = bool
  description = "Bool to control if instance is publicly accessible"
  default     = false
}

variable "db_instance_class" {
  type        = string
  description = "Instance type of the RDS instance"
  default     = "db.t3.small"
}

variable "db_size_in_gb" {
  type        = number
  description = "Storage size in gb of the RDS instance"
  default     = 10
}

variable "db_port" {
  type        = number
  description = "Port number on which the DB accepts connections"
  default     = 5432
}


variable "vpc_private_subnets" {
  type        = list(string)
  description = "list of private subnets created within the vpc"
}

variable "vpc_cidr_block" {
  type        = string
  description = "vpc cidr block ,in which vpc is created "
  default     = "10.0.0.0/16"
}

variable "vpc_id" {
  type        = string
  description = "id of the vpc created "
}

variable "scanfarm_enabled" {
  type        = bool
  description = "it will enable the scanform components"
  default     = false
}

variable "vpc_nat_public_ips" {
  type        = list(string)
  description = "nat public ip to create the ingress controller"
  default     = [""]
}

variable "cluster_endpoint_public_access_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  default     = ["0.0.0.0/0"]
}

variable "deploy_ingress_controller" {
  type        = bool
  description = "Flag to enable/disable the nginx-ingress-controller deployment in the eks cluster"
  default     = true
}

variable "ingress_controller_helm_chart_version" {
  type        = string
  description = "Version of the nginx-ingress-controller helm chart"
  default     = "3.35.0"
}