## VPC outputs
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  value = var.vpc_cidr_block
}

output "vpc_public_subnets" {
  value = module.vpc.public_subnets
}

output "vpc_private_subnets" {
  value = module.vpc.private_subnets
}

output "vpc_nat_public_ips" {
  value = module.vpc.nat_public_ips
}

## Cluster outputs
output "cluster_name" {
  value = "${var.prefix}-cluster"
}

output "cluster_region" {
  value = var.aws_region
}
