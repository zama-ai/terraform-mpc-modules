# Network Environment Configuration
network_environment = "testnet"

enable_region_validation = false

# MPC Party Configuration
party_id   = 2
party_name = "mpc-party-2"

# S3 Bucket Configuration
bucket_prefix   = "zama-kms-decentralized-threshold-2"
config_map_name = "mpc-party"

# Kubernetes Configuration
cluster_name             = "zws-dev"
k8s_namespace            = "kms-decentralized"
k8s_service_account_name = "mpc-party-2"
create_namespace         = false

# IRSA Configuration (recommended for production)
create_irsa = true

# Tagging
tags = {
  "Environment" = "dev"
  "Project"     = "mpc-infrastructure"
  "Example"     = "mpc-party-only"
  "Owner"       = "mpc-team"
  "Terraform"   = "true"
  "Party"       = "mpc-party-2"
}

# RDS Configuration
enable_rds              = false
rds_prefix              = "zama" # Use your organization prefix here
rds_db_name             = "kmsconnector"
rds_username            = "kmsconnector"
rds_deletion_protection = false # Allow deletion of RDS instance

# Node Group Configuration
create_nodegroup                         = true
nodegroup_name                           = "mpc"
nodegroup_instance_types                 = ["c7a.16xlarge"]
nodegroup_min_size                       = 1
nodegroup_max_size                       = 1
nodegroup_desired_size                   = 1
nodegroup_disk_size                      = 30
nodegroup_capacity_type                  = "ON_DEMAND"
nodegroup_ami_type                       = "AL2023_x86_64_STANDARD"
nodegroup_use_latest_ami_release_version = false
# This is the AMI release version recommended by the zama team for the 1.32.3 release. Other versions are not supported.
nodegroup_ami_release_version = "1.32.3-20250620"
nodegroup_labels = {
  "nodepool" = "kms"
}
nodegroup_auto_assign_security_group  = true
nodegroup_enable_nitro_enclaves       = true
nodegroup_enable_ssm_managed_instance = true
# Nitro Enclaves Configuration for MPC Party
kms_enabled_nitro_enclaves = true
# This image attestation SHA must be updated for each KMS enclave release image.
kms_image_attestation_sha   = "5292569b5945693afcde78e5a0045f4bf8c0a594d174baf1e6bccdf0e6338ebe46e89207054e0c48d0ec6deef80284ac"
kms_deletion_window_in_days = 7