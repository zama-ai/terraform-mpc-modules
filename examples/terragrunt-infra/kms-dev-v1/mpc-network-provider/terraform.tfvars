# Network Environment Configuration
network_environment = "testnet"

# AWS Configuration
aws_region               = "eu-west-3"
enable_region_validation = false

cluster_name = "kms-development-v1"
namespace    = "kms-decentralized"
environment  = "dev"
owner        = "zws-team"

# Party Configuration
party_id = "1"

# Kubernetes Provider Configuration
# Option 1: Using kubeconfig context (current method)
kubeconfig_path                = "~/.kube/config"
kubeconfig_context             = "arn:aws:eks:eu-west-3:767398008331:cluster/kms-development-v1"
use_eks_cluster_authentication = true

# VPC Endpoint Services Configuration
# Indicate all aws accounts and regions from which the partner services will be consumed
# By default, the terraform module will add the current region to the supported regions list
allowed_vpc_endpoint_principals = ["arn:aws:iam::715841358639:root"]
vpc_endpoint_supported_regions  = ["eu-west-1"]


vpc_endpoint_acceptance_required = false

# Tagging
common_tags = {
  "terraform"   = "true"
  "module"      = "mpc-cluster-partner-provider"
  "environment" = "dev"
  "Project"     = "mpc-cluster"
  "Example"     = "partner-provider"
  "Mode"        = "provider"
  "ManagedBy"   = "terragrunt"
}