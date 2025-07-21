# Partner Consumer Example
# This example demonstrates how to connect to existing MPC services from partners

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.23"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1"
    }
  }
}

# Configure providers
provider "aws" {
  region = var.aws_region_for_eks != null ? var.aws_region_for_eks : var.aws_region
}

provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = var.kubeconfig_context
  
  dynamic "exec" {
    for_each = var.eks_cluster_name != null ? [1] : []
    content {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_name]
      command     = "aws"
    }
  }
}

# Deploy MPC cluster in consumer mode to connect to partner services
module "mpc_cluster_consumer" {
  source = "../../" # Points to the root module

  # Set deployment mode to consumer
  deployment_mode = "consumer"

  # Cluster configuration
  consumer_cluster_name = var.eks_cluster_name != null ? var.eks_cluster_name : var.cluster_name

  # No MPC services needed in consumer mode (set empty for validation)
  mpc_services = []

  # Partner services configuration - now focused only on service details
  partner_services_config = {
    # Partner services to connect to
    partner_services = var.partner_services

    # VPC Interface Endpoint configuration
    private_dns_enabled = var.private_dns_enabled

    # Tagging
    name_prefix = var.name_prefix
    additional_tags = merge(var.additional_tags, {
      "Environment"     = var.environment
      "Purpose"         = "mpc-partner-connectivity"
      "Mode"            = "consumer"
      "ConfigMethod"    = var.use_eks_cluster_lookup ? "eks-cluster-lookup" : "direct-specification"
    })

    # Kubernetes configuration
    namespace        = var.namespace
    create_namespace = false

    # Custom DNS (optional)
    create_custom_dns_records = var.create_custom_dns_records
    private_zone_id           = var.private_zone_id
    dns_domain                = var.dns_domain

    # Timeouts
    endpoint_create_timeout = var.endpoint_create_timeout
    endpoint_delete_timeout = var.endpoint_delete_timeout
  }

  # Common tags for all resources
  common_tags = merge(var.common_tags, {
    "Environment" = var.environment
    "Project"     = "mpc-cluster"
    "Example"     = "partner-consumer"
    "Owner"       = var.owner
    "Terraform"   = "true"
    "Module"      = "mpc-cluster-partner-consumer"
    "Mode"        = "consumer"
  })
}

# Optional: Random suffix for bucket names to ensure uniqueness
# Uncomment when using mpcParty module
resource "random_id" "bucket_suffix" {
  byte_length = 4
} 