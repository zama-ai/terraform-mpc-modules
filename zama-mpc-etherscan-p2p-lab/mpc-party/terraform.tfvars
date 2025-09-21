# Network Environment Configuration
network_environment = "testnet"

# AWS Configuration
aws_region               = "eu-west-1"
aws_profile              =  "zama-mpc-testnet-user"
enable_region_validation = false

# MPC Party Configuration
party_name  = "etherscan-p2p-lab"
party_id = 12
environment = "dev"

# S3 Bucket Configuration
bucket_prefix   = "zama-kms-decentralized-threshold-2"
config_map_name = "etherscan-p2p-lab-config"

# Kubernetes Configuration
cluster_name         = "zama-mpc-testnet-eks"
namespace            = "kms-decentralized"
service_account_name = "etherscan-p2p-lab-service-account"
create_namespace     = true

# IRSA Configuration (recommended for production)
create_irsa = true

# Kubernetes Provider Configuration
kubeconfig_path    = "~/.kube/config"
kubeconfig_context = "zama-mpc-testnet-eks"

# Tagging
owner = "mpc-team"
additional_tags = {
  "Project"     = "mpc-infrastructure"
  "Team"        = "security"
  "Cost-Center" = "engineering"
}

# RDS Configuration
enable_rds              = true
rds_prefix              = "zama" # Use your organization prefix here
rds_db_name             = "kmsconnector"
rds_username            = "kmsconnector"
rds_enable_master_password_rotation = false # To change to 'false' on second apply only (there is a bug when initializing the value to 'false')
rds_vpc_id          = "vpc-0e4ed8f62c12625e7" # Replace with your private subnet IDs
rds_deletion_protection = true # Allow deletion of RDS instance

# Node Group Configuration
create_nodegroup                         = true
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
nodegroup_additional_security_group_ids = ["sg-0467456f28a762f18"]
nodegroup_enable_nitro_enclaves         = true
nodegroup_enable_ssm_managed_instance   = true
# Nitro Enclaves Configuration for MPC Party
kms_enabled_nitro_enclaves = true
# This image attestation SHA must be updated for each KMS enclave release image.
kms_image_attestation_sha   = "5292569b5945693afcde78e5a0045f4bf8c0a594d174baf1e6bccdf0e6338ebe46e89207054e0c48d0ec6deef80284ac"
kms_deletion_window_in_days = 7