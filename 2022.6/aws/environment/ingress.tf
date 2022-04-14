locals {
  nat_ip_list = [
    for val in var.vpc_nat_public_ips :
    format("%s/32", val)
  ]
  ip_white_list = concat(var.cluster_endpoint_public_access_cidrs, local.nat_ip_list)
  keylist = [
    for val in local.ip_white_list :
    format("controller.service.loadBalancerSourceRanges[%d]", index(local.ip_white_list, val))
  ]
  valuelist = [
    for val in local.ip_white_list :
    val
  ]
  loadBalancerSourceRanges = zipmap(local.keylist, local.valuelist)
  is_eks_cluster_exist     = length(var.cluster_name) > 0 ? true : false
}

# Install the ingress-controller if deploy_ingress_controller flag is enabled
# https://registry.terraform.io/modules/lablabs/eks-ingress-nginx/aws/0.3.0
module "eks-ingress-nginx" {
  source             = "lablabs/eks-ingress-nginx/aws"
  version            = "0.3.0"
  enabled            = var.deploy_ingress_controller
  settings           = local.loadBalancerSourceRanges
  helm_chart_version = var.ingress_controller_helm_chart_version
}