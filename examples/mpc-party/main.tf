# MPC Party Example
# This example demonstrates how to deploy only the MPC party infrastructure
# using the enhanced mpcparty module that handles all Kubernetes resources


# Random suffix for bucket names to ensure uniqueness
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Deploy MPC Party infrastructure using the enhanced mpcparty module
module "mpc_party" {
  source = "../../modules/mpcparty"

  # Party configuration
  party_name               = var.party_name
  vault_private_bucket_name = "${var.bucket_prefix}-private-${random_id.bucket_suffix.hex}"
  vault_public_bucket_name  = "${var.bucket_prefix}-public-${random_id.bucket_suffix.hex}"

  # EKS Cluster configuration
  cluster_name = var.cluster_name

  # Kubernetes configuration - module now handles namespace and service account creation
  k8s_namespace            = var.namespace
  k8s_service_account_name = var.service_account_name
  create_namespace         = var.create_namespace
  create_service_account   = true  # Let module handle service account logic based on IRSA setting

  # Namespace customization
  namespace_labels = {
    "environment"   = var.environment
    "party-name"    = var.party_name
    "example"       = "mpc-party-only"
  }
  
  namespace_annotations = {
    "example.terraform.io/source" = "mpc-party-only"
    "mpc.io/purpose"              = "storage-infrastructure"
  }

  # Service account customization
  service_account_labels = {
    "environment" = var.environment
    "party-name"  = var.party_name
  }

  # IRSA configuration
  create_irsa = var.create_irsa

  # ConfigMap configuration
  create_config_map = true
  config_map_name = var.config_map_name
  additional_config_data = {
    "PARTY_NAME"    = var.party_name
    "ENVIRONMENT"   = var.environment
    "CLUSTER_NAME"  = var.cluster_name
  }

  # Tagging
  common_tags = merge(var.additional_tags, {
    "Environment" = var.environment
    "Project"     = "mpc-infrastructure"
    "Example"     = "mpc-party-only"
    "Owner"       = var.owner
    "Terraform"   = "true"
    "Party"       = var.party_name
  })
} 

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
  count = var.create_nodegroup ? 1 : 0
}

# Create Node Group for MPC Party
module "nodegroup" {
  count = var.create_nodegroup ? 1 : 0
  source = "../../modules/nodegroup"
  name = "mpc-${substr(var.party_name, 0, 8)}-ng"
  cluster_name = var.cluster_name
  instance_types = var.nodegroup_instance_types
  min_size = var.nodegroup_min_size
  max_size = var.nodegroup_max_size
  desired_size = var.nodegroup_desired_size
  ami_type = "AL2_x86_64"
  disk_size = var.nodegroup_disk_size
  taints = {
    dedicated = {
      key = "kms-decentralized"
      value = "true"
      effect = "NO_SCHEDULE"
    }
  }
  labels = {
    "nodepool" = "kms-decentralized"
  }
}