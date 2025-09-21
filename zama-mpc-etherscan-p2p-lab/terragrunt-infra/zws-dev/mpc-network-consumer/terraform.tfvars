# AWS Configuration
enable_region_validation = false

# Network Environment Configuration
network_environment = "testnet"

# Cluster Configuration
cluster_name = "zws-dev"

# Partner Services Namespace
namespace        = "kms-decentralized"
create_namespace = false


# Optional: the following lines if using EKS cluster lookup
# vpc_id                = "vpc-07bff50640cc2dde5"
# subnet_ids           =  [
#   "subnet-0288fe1f3b475d90d",
#   "subnet-051e97122373614c7",
#   "subnet-054a87e337596757a",
# ]

security_group_ids = ["sg-087debb93352a906a"]

# Partner Services Configuration
# IMPORTANT: Update these for each consumer node
party_services = [
  # Example partner service configuration using default ports
  {
    party_id                  = "4"
    name                      = "mpc-node-4"
    region                    = "eu-west-3"
    account_id                = "767398008331"
    partner_name              = "partner-4"
    vpc_endpoint_service_name = "com.amazonaws.vpce.eu-west-3.vpce-svc-0c21caecf930e4d3a"
    create_kube_service       = true
    kube_service_config = {
      additional_annotations = {
        "mpc.io/partner-tier" = "tier-1"
      }
      labels = {
        "partner-name" = "partner-4"
        "environment"  = "dev"
      }
      session_affinity = "None"
    }
  }
]

# VPC Endpoint Configuration
private_dns_enabled = false
name_prefix         = "mpc-partner"
enable_grpc_port    = false

# Timeouts
endpoint_create_timeout = "15m"
endpoint_delete_timeout = "10m"

# Custom DNS (optional)
create_custom_dns_records = false
private_zone_id           = ""

# Tagging
tags = {
  "terraform"   = "true"
  "module"      = "mpc-network-consumer"
  "environment" = "dev"
  "ManagedBy"   = "terragrunt"
  "Project"     = "mpc-connectivity"
  "Example"     = "partner-consumer-direct"
  "Owner"       = "zws-team"
}