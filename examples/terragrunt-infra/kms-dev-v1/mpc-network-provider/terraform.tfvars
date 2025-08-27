# Network Environment Configuration
network_environment = "testnet"

# AWS Configuration
enable_region_validation = false

namespace        = "kms-decentralized"
create_namespace = false

# Party Configuration
party_id = "4"

# VPC Endpoint Services Configuration
# Indicate all aws accounts and regions from which the partner services will be consumed
# By default, the terraform module will add the current region to the supported regions list
allowed_principals  = ["arn:aws:iam::715841358639:root"]
supported_regions   = ["eu-west-1"]
acceptance_required = false

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