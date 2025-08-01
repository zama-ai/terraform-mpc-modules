aws_region         = "eu-west-3"
aws_region_for_eks = "eu-west-3"

cluster_name = "kms-development-v1"
namespace    = "kms-decentralized"
environment  = "dev"
owner        = "zws-team"

# Kubernetes Provider Configuration
# Option 1: Using kubeconfig context (current method)
kubeconfig_path    = "~/.kube/config"
kubeconfig_context = "arn:aws:eks:eu-west-3:767398008331:cluster/kms-development-v1"


# MPC Services Configuration
mpc_services = [
  {
    name = "mpc-node-4"
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
      }
    ]
    selector = {
      "app" = "kms-core"
      "app.kubernetes.io/name" = "kms-threshold-4-core"
    }
    additional_annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "mpc-node=node-1,environment=dev"
    }
    labels = {
      "mpc-role"    = "compute-node"
      "environment" = "dev"
      "app" = "kms-core"
      "app.kubernetes.io/name" = "kms-threshold-4-core"
    }
  },
]

# VPC Endpoint Services Configuration
create_vpc_endpoints              = true

# Indicate all aws accounts and regions from which the partner services will be consumed
# By default, the terraform module will add the current region to the supported regions list
allowed_vpc_endpoint_principals  = ["arn:aws:iam::715841358639:root"]
vpc_endpoint_supported_regions   = ["eu-west-1"]


vpc_endpoint_acceptance_required = false
create_custom_dns = false
private_zone_id   = ""
dns_domain        = ""

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