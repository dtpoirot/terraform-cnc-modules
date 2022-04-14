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

## VPC configuration
variable "create_vpc" {
  type        = bool
  description = "controls if VPC should be created"
  default     = true
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_id" {
  type        = string
  description = "ID of the existing VPC"
  default     = ""
}

## EKS cluster configuration
variable "create_eks" {
  type        = bool
  description = "controls if EKS should be created"
  default     = true
}

variable "scanfarm_enabled" {
  type        = bool
  description = "Whether scanfarm resources have to be created or not; Defaults to false (BETA)"
  default     = false
}

variable "cluster_name" {
  type        = string
  description = "Name of the existing EKS cluster; if empty, then EKS cluster will be created"
  default     = ""
}

variable "map_users" {
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  description = "Additional IAM users to add to the aws-auth configmap"
  default     = []
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version of the EKS cluster"
  default     = "1.21"
}

variable "cluster_endpoint_public_access_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  default     = ["0.0.0.0/0"]
}

variable "cluster_create_timeout" {
  type        = string
  description = "Timeout value when creating the EKS cluster."
  default     = "60m"
}

variable "deploy_autoscaler" {
  type        = bool
  description = "Flag to enable/disable the cluster-autoscaler deployment in the eks cluster"
  default     = true
}

variable "cluster_autoscaler_helm_chart_version" {
  type        = string
  description = "Version of the cluster-autoscaler helm chart "
  default     = "9.10.4"
}

## Default node pool configuration
variable "default_node_pool_instance_type" {
  type        = string
  description = "Instance type of each node in a default node pool"
  default     = "m5d.2xlarge"
}

variable "default_node_pool_ami_type" {
  type        = string
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group"
  default     = "AL2_x86_64"
}

variable "default_node_pool_disk_size" {
  type        = number
  description = "Disk size in gb for each node in a default node pool"
  default     = 50
}

variable "default_node_pool_capacity_type" {
  type        = string
  description = "Type of instance capacity to provision default node pool. Options are ON_DEMAND and SPOT"
  default     = "ON_DEMAND"
}

variable "default_node_pool_min_size" {
  type        = number
  description = "Min number of nodes in a default node pool"
  default     = 3
}

variable "default_node_pool_max_size" {
  type        = number
  description = "Max number of nodes in a default node pool"
  default     = 9
}

## Jobfarm node pool configuration
variable "jobfarm_node_pool_instance_type" {
  type        = string
  description = "Instance type of each node in a jobfarm node pool"
  default     = "m5d.2xlarge"
}

variable "jobfarm_node_pool_ami_type" {
  type        = string
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group"
  default     = "AL2_x86_64"
}

variable "jobfarm_node_pool_disk_size" {
  type        = number
  description = "Disk size in gb for each node in a jobfarm node pool "
  default     = 100
}

variable "jobfarm_node_pool_capacity_type" {
  type        = string
  description = "Type of instance capacity to provision jobfarm node pool. Options are ON_DEMAND and SPOT"
  default     = "SPOT"
}

variable "jobfarm_node_pool_min_size" {
  type        = number
  description = "Min number of nodes in a jobfarm node pool"
  default     = 0
}

variable "jobfarm_node_pool_max_size" {
  type        = number
  description = "Max number of nodes in a jobfarm node pool"
  default     = 50
}

variable "jobfarm_node_pool_taints" {
  type        = list(any)
  description = "Taints for the jobfarm node pool"
  default = [
    {
      key    = "NodeType"
      value  = "ScannerNode"
      effect = "NO_SCHEDULE"
    }
  ]
}
