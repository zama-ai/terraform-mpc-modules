# MPC Party Example
# This example demonstrates how to deploy only the MPC party infrastructure
# using the enhanced mpc-party module that handles all Kubernetes resources

# Deploy MPC Party infrastructure using the enhanced mpc-party module
module "mpc_party" {
  source = "git::https://github.com/zama-ai/terraform-mpc-modules.git//modules/mpc-party?ref=v0.1.9"
  #source = "../../modules/mpc-party"
  # Network environment configuration
  network_environment      = var.network_environment
  #enable_region_validation = var.enable_region_validation

  # Party configuration
  party_id      = var.party_id
  party_name    = var.party_name
  bucket_prefix = var.bucket_prefix

  # EKS Cluster configuration
  cluster_name = var.cluster_name

  # Kubernetes configuration - module now handles namespace and service account creation
  k8s_namespace            = var.namespace
  k8s_service_account_name = var.service_account_name
  create_namespace         = var.create_namespace
  create_service_account   = true # Let module handle service account logic based on IRSA setting

  # Namespace customization
  namespace_labels = {
    "environment" = var.environment
    "party-name"  = var.party_name
    "example"     = "mpc-party-only"
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
  config_map_name   = var.config_map_name

  # Node Group configuration
  create_nodegroup               = var.create_nodegroup
  nodegroup_name                 = var.nodegroup_name
  nodegroup_instance_types       = var.nodegroup_instance_types
  nodegroup_min_size             = var.nodegroup_min_size
  nodegroup_max_size             = var.nodegroup_max_size
  nodegroup_desired_size         = var.nodegroup_desired_size
  nodegroup_disk_size            = var.nodegroup_disk_size
  nodegroup_capacity_type        = var.nodegroup_capacity_type
  nodegroup_ami_type             = var.nodegroup_ami_type
  nodegroup_enable_remote_access = var.nodegroup_enable_remote_access
  nodegroup_ec2_ssh_key          = var.nodegroup_ec2_ssh_key
  nodegroup_labels               = var.nodegroup_labels

  kms_image_attestation_sha                = var.kms_image_attestation_sha
  kms_deletion_window_in_days              = var.kms_deletion_window_in_days
  nodegroup_additional_security_group_ids  = var.nodegroup_additional_security_group_ids
  nodegroup_enable_ssm_managed_instance    = var.nodegroup_enable_ssm_managed_instance
  nodegroup_use_latest_ami_release_version = var.nodegroup_use_latest_ami_release_version
  nodegroup_ami_release_version            = var.nodegroup_ami_release_version

  # Nitro Enclaves Configuration
  kms_enabled_nitro_enclaves         = var.kms_enabled_nitro_enclaves
  nodegroup_enable_nitro_enclaves    = var.nodegroup_enable_nitro_enclaves
  nitro_enclaves_override_cpu_count  = var.nitro_enclaves_override_cpu_count
  nitro_enclaves_override_memory_mib = var.nitro_enclaves_override_memory_mib

  # RDS Configuration
  enable_rds                                = var.enable_rds
  rds_db_name                               = var.rds_db_name
  rds_create_monitoring_role                = var.rds_create_monitoring_role
  #rds_manage_master_user_password           = var.rds_manage_master_user_password
  rds_username                              = var.rds_username
  rds_engine                                = var.rds_engine
  rds_engine_version                        = var.rds_engine_version
  rds_instance_class                        = var.rds_instance_class
  rds_allocated_storage                     = var.rds_allocated_storage
  rds_max_allocated_storage                 = var.rds_max_allocated_storage
  rds_multi_az                              = var.rds_multi_az
  rds_backup_retention_period               = var.rds_backup_retention_period
  rds_maintenance_window                    = var.rds_maintenance_window
  rds_monitoring_interval                   = var.rds_monitoring_interval
  rds_monitoring_role_arn                   = var.rds_monitoring_role_arn
  #rds_performance_insights_enabled          = var.rds_performance_insights_enabled
  #rds_performance_insights_kms_key_id       = var.rds_performance_insights_kms_key_id
  #rds_performance_insights_retention_period = var.rds_performance_insights_retention_period
  #rds_blue_green_update_enabled             = var.rds_blue_green_update_enabled
  rds_parameters                            = var.rds_parameters
  #rds_snapshot_identifier                   = var.rds_snapshot_identifier
  #rds_final_snapshot_enabled                = var.rds_final_snapshot_enabled
  #rds_k8s_secret_name                       = var.rds_k8s_secret_name
  #rds_k8s_secret_namespace                  = var.rds_k8s_secret_namespace
  rds_allowed_cidr_blocks                   = var.rds_allowed_cidr_blocks
  rds_vpc_id                                = var.rds_vpc_id
  #rds_subnet_ids                            = var.rds_subnet_ids
  rds_deletion_protection                   = var.rds_deletion_protection
  rds_master_password_rotation_days         = var.rds_master_password_rotation_days

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


# Terraform: create a dedicated EKS Managed Node Group for Nitro
resource "aws_eks_node_group" "nitro_ng" {
  cluster_name    = var.cluster_name
  node_group_name = "nitro_ng"
  node_role_arn   = "arn:aws:iam::455309426926:role/mpc-party-nodegroup-eks-node-group-20250919031002116900000001"
  subnet_ids      = ["subnet-0b7a706ae7eae6809", "subnet-03437f7c685339999", "subnet-0a368495c072e860b"]

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 3
  }

  instance_types = ["t3.xlarge"] # or c7a.large/m7a.large etc

  disk_size = 50

  labels = {
    role     = "nitro"
    workload = "zama-nitro"
  }

  taint {
    key    = "nitro"
    value  = "only"
    effect = "NO_SCHEDULE"
  }
}


