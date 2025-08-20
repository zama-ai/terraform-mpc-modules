# AWS Configuration
aws_region         = "eu-west-1"
enable_region_validation = false

# Network Environment Configuration
network_environment = "testnet"

# MPC Cluster Configuration
cluster_name = "tailscale-operator-zws-dev.diplodocus-boa.ts.net"
namespace    = "kms-decentralized"
environment  = "dev"
owner        = "zws-team"

# Kubernetes Provider Configuration
kubeconfig_path    = "~/.kube/config"
kubeconfig_context = "tailscale-operator-zws-dev.diplodocus-boa.ts.net"

# MPC Party Configuration
party_id = "2"

# VPC Endpoint Services Configuration

# Indicate all aws accounts and regions from which the partner services will be consumed
# By default, the terraform module will add the current region to the supported regions list
allowed_vpc_endpoint_principals  = ["arn:aws:iam::767398008331:root"]
vpc_endpoint_supported_regions   = ["eu-west-3"]

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