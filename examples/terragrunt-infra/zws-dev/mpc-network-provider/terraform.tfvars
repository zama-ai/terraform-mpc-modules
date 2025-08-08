# Partner Provider MPC Cluster Configuration
# ZWS Dev Environment - Provider Side (Terragrunt Managed)

# AWS Configuration
aws_region         = "eu-west-1"
aws_region_for_eks = "eu-west-1"

# MPC Cluster Configuration
cluster_name = "tailscale-operator-zws-dev.diplodocus-boa.ts.net"
namespace    = "kms-decentralized"
environment  = "dev"
owner        = "zws-team"

# Kubernetes Provider Configuration
# Option 1: Using kubeconfig context (current method)
kubeconfig_path    = "~/.kube/config"
kubeconfig_context = "tailscale-operator-zws-dev.diplodocus-boa.ts.net"


# MPC Services Configuration
mpc_services = [
  {
    name = "mpc-node-1"
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
        port        = 9090
        target_port = 9090
        protocol    = "TCP"
      }
    ]
    selector = {
      "app" = "kms-core"
      "app.kubernetes.io/name" = "kms-threshold-1-core"
    }
    additional_annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "mpc-node=node-1,environment=dev"
    }
    labels = {
      "mpc-role"    = "compute-node"
      "environment" = "dev"
      "app" = "kms-core"
      "app.kubernetes.io/name" = "kms-threshold-1-core"
    }
  },
  {
    name = "mpc-node-2"
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
      "app.kubernetes.io/name" = "kms-threshold-2-core"
    }
    additional_annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "mpc-node=node-2,environment=dev"
    }
    labels = {
      "mpc-role"    = "compute-node"
      "environment" = "dev"
      "app" = "kms-core"
      "app.kubernetes.io/name" = "kms-threshold-2-core"
    }
  },
  {
    name = "mpc-node-3"
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
      "app.kubernetes.io/name" = "kms-threshold-3-core"
    }
    additional_annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "mpc-node=node-3,environment=dev"
    }
    labels = {
      "mpc-role"    = "compute-node"
      "environment" = "dev"
      "app" = "kms-core"
      "app.kubernetes.io/name" = "kms-threshold-3-core"
    }
  }
]

# VPC Endpoint Services Configuration

# Indicate all aws accounts and regions from which the partner services will be consumed
# By default, the terraform module will add the current region to the supported regions list
allowed_vpc_endpoint_principals  = ["arn:aws:iam::767398008331:root"]
vpc_endpoint_supported_regions   = ["eu-west-3"]

vpc_endpoint_acceptance_required = false
# Custom DNS Configuration (disabled for this environment)
create_custom_dns = false
dns_domain        = "mpc.internal"

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