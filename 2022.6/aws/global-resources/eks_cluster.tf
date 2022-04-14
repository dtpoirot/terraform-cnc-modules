# Create the eks cluster if create_eks flag is enabled
# https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/17.3.0
module "eks" {
  source                               = "terraform-aws-modules/eks/aws"
  version                              = "17.3.0"
  create_eks                           = var.create_eks
  cluster_name                         = "${var.prefix}-cluster"
  cluster_version                      = var.kubernetes_version
  vpc_id                               = module.vpc.vpc_id
  subnets                              = module.vpc.public_subnets
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  enable_irsa                          = true
  map_users                            = var.map_users
  cluster_create_timeout               = var.cluster_create_timeout
  tags                                 = var.tags
  write_kubeconfig                     = false

  # https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/17.3.0/submodules/node_groups
  node_groups = merge(
    {
      app_nodepool = {
        key_name         = ""
        name_prefix      = "app_nodepool_"
        desired_capacity = var.default_node_pool_min_size
        min_capacity     = var.default_node_pool_min_size
        max_capacity     = var.default_node_pool_max_size
        ami_type         = var.default_node_pool_ami_type
        instance_types   = [var.default_node_pool_instance_type]
        disk_size        = var.default_node_pool_disk_size
        capacity_type    = var.default_node_pool_capacity_type
        k8s_labels = {
          app       = "jobfarm"
          pool-type = "app"
        }
        subnets = module.vpc.private_subnets
      }
    }, local.scanfarm_node_pools
  )
}

# If eks cluster already exists
locals {
  scanfarm_node_pools = var.scanfarm_enabled ? {
    small_exec_pool = {
      key_name         = ""
      name_prefix      = "small_exec_pool_"
      desired_capacity = 1
      min_capacity     = var.jobfarm_node_pool_min_size
      max_capacity     = var.jobfarm_node_pool_max_size
      ami_type         = var.jobfarm_node_pool_ami_type
      instance_types   = [var.jobfarm_node_pool_instance_type]
      disk_size        = var.jobfarm_node_pool_disk_size
      capacity_type    = var.jobfarm_node_pool_capacity_type
      k8s_labels = {
        app       = "jobfarm"
        pool-type = "small"
      }
      subnets = module.vpc.private_subnets
      taints  = var.jobfarm_node_pool_taints
  } } : {}

  is_eks_cluster_exist = length(var.cluster_name) > 0 ? true : false
}

# Get the eks cluster resources
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster
data "aws_eks_cluster" "cluster" {
  name = local.is_eks_cluster_exist ? var.cluster_name : module.eks.cluster_id
}

# Get the eks cluster auth resources to connect the cluster
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth
data "aws_eks_cluster_auth" "cluster" {
  name = local.is_eks_cluster_exist ? var.cluster_name : module.eks.cluster_id
}

# Install the cluster-autoscaler if deploy_autoscaler flag is enabled
# https://registry.terraform.io/modules/lablabs/eks-cluster-autoscaler/aws/1.4.0
module "eks-cluster-autoscaler" {
  source                           = "lablabs/eks-cluster-autoscaler/aws"
  version                          = "1.4.0"
  enabled                          = var.deploy_autoscaler
  cluster_name                     = module.eks.cluster_id
  cluster_identity_oidc_issuer     = module.eks.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = module.eks.oidc_provider_arn
  helm_chart_version               = var.cluster_autoscaler_helm_chart_version
}