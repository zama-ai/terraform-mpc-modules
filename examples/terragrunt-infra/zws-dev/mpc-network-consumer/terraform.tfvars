# This is a test file for the kms-dev-v1 consumer node

# AWS Configuration
aws_region         = "eu-west-1"
aws_region_for_eks = "eu-west-1"

# Cluster Configuration
cluster_name = "zws-dev"
environment  = "dev"
owner        = "mpc-consumer-team"

# Kubernetes Provider Configuration
# IMPORTANT: Update these values for each consumer node
kubeconfig_path    = "~/.kube/config"
kubeconfig_context = "tailscale-operator-zws-dev.diplodocus-boa.ts.net"  # Set to specific context or null to use current
eks_cluster_name   = "zws-dev"  # Update for EKS authentication

# Partner Services Namespace
namespace        = "kms-decentralized"

# Network Configuration for VPC Endpoints
# Option 1: Use EKS cluster lookup (recommended)
# Leave vpc_id and subnet_ids null to use cluster_name lookup
# use_eks_cluster_lookup = true
# vpc_id                = null
# subnet_ids           = null
# security_group_ids   = null

# Option 2: Direct VPC specification
use_eks_cluster_lookup = false
vpc_id                = "vpc-07bff50640cc2dde5"
subnet_ids           =  [
  "subnet-0288fe1f3b475d90d",
  "subnet-051e97122373614c7",
  "subnet-054a87e337596757a",
]
security_group_ids   = ["sg-087debb93352a906a"]

# Partner Services Configuration
# IMPORTANT: Update these for each consumer node
party_services = [
  # Example partner service configuration
  {
    name                      = "mpc-node-4"
    region                    = "eu-west-3"
    account_id                = "767398008331"
    partner_name              = "party-4"
    vpc_endpoint_service_name = "com.amazonaws.vpce.eu-west-3.vpce-svc-0432e3f717883982d"
    // TODO put in module
    ports = [
      {
        name        = "grpc"
        port        = 50100
        target_port = 50100
        protocol    = "TCP"
      },
      {
        name        = "peer"
        port        = 50001
        target_port = 50001
        protocol    = "TCP"
      },
      {
        name        = "metrics"
        port        = 9646
        target_port = 9646
        protocol    = "TCP"
      },
    ]
    create_kube_service = true
    // TODO put in module
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