# AWS Configuration
aws_region         = "eu-west-3"
enable_region_validation = false

# Network Environment Configuration
network_environment = "testnet"

# Cluster Configuration
cluster_name = "kms-development-v1"
environment  = "dev"
owner        = "mpc-consumer-team"

# Kubernetes Provider Configuration
# IMPORTANT: Update these values for each consumer node
kubeconfig_path    = "~/.kube/config"
kubeconfig_context = "arn:aws:eks:eu-west-3:767398008331:cluster/kms-development-v1"  # Set to specific context or null to use current

# Partner Services Namespace
namespace        = "kms-decentralized"

# Option: the following lines if using EKS cluster lookup
# vpc_id             = "vpc-0eb96948db410744b"
# subnet_ids         = ["subnet-0027932ed0306303c", "subnet-048864a6944214156", "subnet-0c62aabc99b5f0a27"]

security_group_ids = ["sg-033017badc63f1e10"]

# Partner Services Configuration
# IMPORTANT: Update these for each consumer node
party_services = [
  # Example partner service configuration
  {
    party_id                  = "2"
    name                      = "mpc-node-2"
    region                    = "eu-west-1"
    account_id                = "715841358639"
    partner_name              = "partner-2"
    vpc_endpoint_service_name = "com.amazonaws.vpce.eu-west-1.vpce-svc-015ed042eebeed9e3"
    create_kube_service = true
    kube_service_config = {
      additional_annotations = {
        "mpc.io/partner-tier" = "tier-1"
      }
      labels = {
        "partner-name" = "partner-2"
        "environment"  = "dev"
      }
      session_affinity = "None"
    }
  },
]

# VPC Endpoint Configuration
private_dns_enabled = false
name_prefix         = "mpc-partner"

# Timeouts
endpoint_create_timeout = "15m"
endpoint_delete_timeout = "10m"

# Custom DNS (optional)
create_custom_dns_records = false
private_zone_id           = ""
dns_domain                = ""

# Tagging
common_tags = {
  "terraform"   = "true"
  "module"      = "partner-consumer-direct"
  "environment" = "dev"
}

additional_tags = {
  "Project"     = "mpc-connectivity"
}