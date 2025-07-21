# Partner Consumer Example Configuration Template
# This example uses direct modules for clean separation of concerns
# Copy this file to terraform-nodeX.tfvars and customize the values

# AWS Configuration
aws_region         = "eu-west-3"
aws_region_for_eks = "eu-west-3"

# Cluster Configuration
cluster_name = "consumer-mpc-cluster"
environment  = "dev"
owner        = "mpc-consumer-team"

# Kubernetes Provider Configuration
# IMPORTANT: Update these values for each consumer node
kubeconfig_path    = "~/.kube/config"
kubeconfig_context = null  # Set to specific context or null to use current
eks_cluster_name   = "consumer-mpc-cluster"  # Update for EKS authentication

# Partner Services Namespace
namespace        = "mpc-partners"

# Network Configuration for VPC Endpoints
# Option 1: Use EKS cluster lookup (recommended)
# Leave vpc_id and subnet_ids null to use cluster_name lookup
use_eks_cluster_lookup = true
vpc_id                = null
subnet_ids           = null
security_group_ids   = null

# Option 2: Direct VPC specification
# Uncomment and specify if not using cluster lookup
# use_eks_cluster_lookup = false
# vpc_id             = "vpc-1234567890abcdef0"
# subnet_ids         = ["subnet-1234567890abcdef0", "subnet-0987654321fedcba0"]
# security_group_ids = ["sg-1234567890abcdef0"]

# Partner Services Configuration
# IMPORTANT: Update these for each consumer node
partner_services = [
  # Example partner service configuration
  # {
  #   name                      = "partner-mpc-node-1"
  #   region                    = "eu-west-1"
  #   account_id                = "715841358639"
  #   vpc_endpoint_service_name = "com.amazonaws.vpce.eu-west-1.vpce-svc-0af347d565de9f03d"
  #   ports = [
  #     {
  #       name        = "grpc"
  #       port        = 50100
  #       target_port = 50100
  #       protocol    = "TCP"
  #     },
  #     {
  #       name        = "peer"
  #       port        = 50001
  #       target_port = 50001
  #       protocol    = "TCP"
  #     },
  #     {
  #       name        = "metrics"
  #       port        = 9646
  #       target_port = 9646
  #       protocol    = "TCP"
  #     },
  #   ]
  #   create_kube_service = true
  #   kube_service_config = {
  #     additional_annotations = {
  #       "mpc.io/partner-tier" = "tier-1"
  #     }
  #     labels = {
  #       "partner-name" = "partner-1"
  #       "environment"  = "dev"
  #     }
  #     session_affinity = "None"
  #   }
  # }
]

# VPC Endpoint Configuration
private_dns_enabled = true
name_prefix         = "mpc-partner"

# Timeouts
endpoint_create_timeout = "15m"
endpoint_delete_timeout = "10m"

# Custom DNS (optional)
create_custom_dns_records = false
# private_zone_id           = "Z1234567890ABC"
# dns_domain                = "mpc-partners.internal"

# Optional: Enable MPC Party Storage
enable_mpc_party_storage = false

# If enabling MPC party storage, configure these:
# enable_mpc_party_storage       = true
# mpc_party_name                 = "consumer-party-dev"
# bucket_prefix                  = "mpc-consumer-vault"
# mpc_party_namespace            = "mpc-storage"
# mpc_party_service_account_name = "mpc-consumer-sa"
# create_mpc_party_namespace     = true
# create_irsa                    = true

# Tagging
common_tags = {
  "terraform"   = "true"
  "module"      = "partner-consumer-direct"
  "environment" = "dev"
}

additional_tags = {
  "Project"     = "mpc-connectivity"
  "Team"        = "mpc-consumer-team"
  "Cost-Center" = "engineering"
}

# =============================================================================
# USAGE EXAMPLES
# =============================================================================

# To use different consumer node configurations:
# 1. Copy terraform-node1.tfvars for consumer node 1 (original config)
# 2. Copy terraform-node2.tfvars for consumer node 2 (example additional config)
# 3. Create additional terraform-nodeX.tfvars files as needed

# Run with specific config:
# terraform plan -var-file="terraform-node1.tfvars"
# terraform apply -var-file="terraform-node1.tfvars"

# Or:
# terraform plan -var-file="terraform-node2.tfvars"
# terraform apply -var-file="terraform-node2.tfvars" 