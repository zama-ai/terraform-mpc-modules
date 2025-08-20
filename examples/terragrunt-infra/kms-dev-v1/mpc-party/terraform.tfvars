# Network Environment Configuration
network_environment = "testnet"

# AWS Configuration
aws_region = "eu-west-3"
enable_region_validation = false

# MPC Party Configuration
party_name  = "mpc-party-4"
environment = "dev"

# S3 Bucket Configuration
bucket_prefix = "zama-kms-decentralized-threshold-4"
config_map_name = "mpc-party-4"

# Kubernetes Configuration
cluster_name         = "kms-development-v1"
namespace           = "kms-decentralized"
service_account_name = "mpc-party-4"
create_namespace    = false

# IRSA Configuration (recommended for production)
create_irsa = true

# Kubernetes Provider Configuration
kubeconfig_path    = "~/.kube/config"
kubeconfig_context = "arn:aws:eks:eu-west-3:767398008331:cluster/kms-development-v1"
eks_cluster_name   = "kms-development-v1"  # For automatic EKS token authentication

# Tagging
owner = "mpc-team"
additional_tags = {
  "Project"     = "mpc-infrastructure"
  "Team"        = "security"
  "Cost-Center" = "engineering"
}

# RDS Configuration
enable_rds = false
rds_db_name = "kms-connector"

# Node Group Configuration
create_nodegroup = true
nodegroup_instance_types = ["m5.2xlarge"]
nodegroup_min_size = 1
nodegroup_max_size = 1
nodegroup_desired_size = 1
nodegroup_disk_size = 30
nodegroup_capacity_type = "ON_DEMAND"
# After 1.30.0 release, we need to use AL2023_x86_64_STANDARD
nodegroup_ami_type = "AL2023_x86_64_STANDARD"
nodegroup_labels = {
  "nodepool" = "kms"
}
nodegroup_taints = {}
nodegroup_additional_security_group_ids = ["sg-0e4f24b603b57f590"]
nodegroup_enable_nitro_enclaves = true
# nodegroup_enable_ssm_managed_instance = true

# Nitro Enclaves Configuration for MPC Party
kms_enabled_nitro_enclaves = true
kms_image_attestation_sha = "fb386ef9ea16263dd1bba744c9b86eaa7a11401f13f6033e48b9b8e6c718bc71f3070ccafd9fab1535ec406975dff43d"
kms_deletion_window_in_days = 7