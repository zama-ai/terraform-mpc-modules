# Network Environment Configuration
network_environment = "testnet"

# AWS Configuration
enable_region_validation = false

namespace        = "kms-decentralized"
create_namespace = false

# Party Configuration
party_id     = "4"
partner_name = "zama"

# VPC Endpoint Services Configuration
# Indicate all aws accounts and regions from which the partner services will be consumed
# By default, the terraform module will add the current region to the supported regions list
allowed_principals  = ["arn:aws:iam::715841358639:root"]
supported_regions   = ["eu-west-1", "eu-west-3"]
acceptance_required = false
enable_grpc_port    = false

sync_public_bucket = {
  enabled        = true
  configmap_name = "mpc-party"
}

# Tagging
tags = {
  "terraform"   = "true"
  "module"      = "mpc-cluster-partner-provider"
  "environment" = "dev"
  "Project"     = "mpc-cluster"
  "Example"     = "partner-provider"
  "Mode"        = "provider"
  "ManagedBy"   = "terragrunt"
}
