# Partner Provider MPC Cluster Example
# This example demonstrates how to deploy an MPC cluster as a service provider with:
# - Multiple MPC services with NLBs
# - VPC endpoint services for exposing services to partners
# - Custom tagging and configuration

#terraform {
#   required_version = ">= 1.0"
# 
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = ">= 5.0"
#     }
#     kubernetes = {
#       source  = "hashicorp/kubernetes"
#       version = ">= 2.23"
#     }
#     random = {
#       source  = "hashicorp/random"
#       version = ">= 3.1"
#     }
#   }
#   backend "s3" {}
# }
# 
# # Configure providers
# provider "aws" {
#   region = var.aws_region_for_eks != null ? var.aws_region_for_eks : var.aws_region
# }
# 
# provider "kubernetes" {
#   config_path    = var.kubeconfig_path
#   config_context = var.kubeconfig_context
#   
#   dynamic "exec" {
#     for_each = var.eks_cluster_name != null ? [1] : []
#     content {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_name]
#       command     = "aws"
#     }
#   }
# }

locals {
  allowed_principals   = var.allowed_vpc_endpoint_principals
  cluster_name        = var.cluster_name
  namespace           = var.namespace
  environment         = var.environment
  create_vpc_endpoints = var.create_vpc_endpoints
}

# Deploy the complete MPC cluster
module "mpc_cluster" {
  source = "../../" # Points to the root module

  # Cluster configuration
  cluster_name     = local.cluster_name
  namespace        = local.namespace
  create_namespace = false

  # MPC services configuration
  mpc_services = var.mpc_services

  # VPC endpoint services configuration (provider side)
  create_vpc_endpoints = local.create_vpc_endpoints
  vpc_endpoints_config = {
    acceptance_required = var.vpc_endpoint_acceptance_required
    allowed_principals  = local.allowed_principals
    supported_regions   = var.vpc_endpoint_supported_regions
  }

  # Common tags for all resources
  common_tags = merge(var.common_tags, {
    "Environment" = var.environment
    "Owner"       = var.owner
  })

  # Optional: Enable MPC Party infrastructure (S3 buckets and IRSA)
  # Uncomment to enable storage infrastructure for this MPC party
  # enable_mpc_party = true
  # mpc_party_config = {
  #   party_name                = "provider-party-${var.environment}"
  #   vault_private_bucket_name = "mpc-provider-private-vault-${var.environment}-${random_id.bucket_suffix.hex}"
  #   vault_public_bucket_name  = "mpc-provider-public-vault-${var.environment}-${random_id.bucket_suffix.hex}"
  #   k8s_service_account_name  = "mpc-provider-sa"
  #   create_irsa               = true
  # }

  # Timeouts
  service_create_timeout = "10m"
}

# Optional: Random suffix for bucket names to ensure uniqueness
# Uncomment when using mpcParty module
# resource "random_id" "bucket_suffix" {
#   byte_length = 4
# } 