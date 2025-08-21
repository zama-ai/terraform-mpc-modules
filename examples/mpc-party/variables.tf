# Network Environment Configuration
variable "network_environment" {
  description = "MPC network environment that determines region constraints"
  type        = string
  default     = "testnet"

  validation {
    condition     = contains(["testnet", "mainnet"], var.network_environment)
    error_message = "Network environment must be either 'testnet' or 'mainnet'."
  }
}

variable "aws_region" {
  description = "AWS region for MPC network deployment (validated against network environment)"
  type        = string
  default     = "eu-west-1"
}

variable "enable_region_validation" {
  type        = bool
  description = "Whether to enable region validation"
  default     = true
}

# MPC Party Configuration
variable "party_name" {
  description = "Name of the MPC party (used for tagging and resource naming)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.party_name))
    error_message = "Party name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "config_map_name" {
  description = "Name of the ConfigMap (defaults to 'mpc-party-config-{party_name}' if not provided)"
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod", "test"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, test."
  }
}

# S3 Bucket Configuration
variable "bucket_prefix" {
  description = "Prefix for S3 bucket names"
  type        = string
  default     = "mpc-vault"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.bucket_prefix))
    error_message = "Bucket prefix must contain only lowercase letters, numbers, and hyphens."
  }
}

# Kubernetes Configuration
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for MPC party resources"
  type        = string
  default     = "mpc-party"
}

variable "service_account_name" {
  description = "Name of the Kubernetes service account for MPC party"
  type        = string
  default     = "mpc-party-sa"
}

variable "create_namespace" {
  description = "Whether to create the Kubernetes namespace (handled by mpc-party module)"
  type        = bool
  default     = true
}

# IRSA Configuration
variable "create_irsa" {
  description = "Whether to create IRSA (IAM Roles for Service Accounts) role for secure AWS access"
  type        = bool
  default     = true
}

# Kubernetes Provider Configuration
variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "kubeconfig_context" {
  description = "Kubernetes context to use from kubeconfig"
  type        = string
  default     = null
}

variable "eks_cluster_name" {
  description = "EKS cluster name for automatic token authentication (optional, used for exec auth)"
  type        = string
  default     = null
}

# Tagging
variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "owner" {
  description = "Owner of the resources for tagging purposes"
  type        = string
  default     = "mpc-team"
}

variable "create_nodegroup" {
  description = "Whether to create a nodegroup for the MPC party"
  type        = bool
  default     = false
}

variable "nodegroup_instance_types" {
  description = "Instance types for the nodegroup"
  type        = list(string)
  default     = ["t3.large"]
}

variable "nodegroup_min_size" {
  description = "Minimum number of nodes in the nodegroup"
  type        = number
  default     = 1
}

variable "nodegroup_max_size" {
  description = "Maximum number of nodes in the nodegroup"
  type        = number
  default     = 1
}

variable "nodegroup_desired_size" {
  description = "Desired number of nodes in the nodegroup"
  type        = number
  default     = 1
}

variable "nodegroup_disk_size" {
  description = "Disk size for the nodegroup"
  type        = number
  default     = 30
}

variable "nodegroup_capacity_type" {
  description = "Capacity type for the nodegroup"
  type        = string
  default     = "ON_DEMAND"
}

variable "nodegroup_ami_type" {
  description = "AMI type for the nodegroup"
  type        = string
  default     = "AL2_x86_64"
}

variable "nodegroup_enable_remote_access" {
  description = "Whether to enable remote access to the nodegroup"
  type        = bool
  default     = false
}

variable "nodegroup_ec2_ssh_key" {
  description = "EC2 Key Pair name that provides access for SSH communication with the worker nodes"
  type        = string
  default     = null
}

variable "nodegroup_source_security_group_ids" {
  description = "List of security group IDs allowed for remote access"
  type        = list(string)
  default     = []
}

variable "nodegroup_labels" {
  description = "Labels for the nodegroup"
  type        = map(string)
  default = {
    "nodepool" = "kms"
  }
}

variable "nodegroup_enable_nitro_enclaves" {
  description = "Whether to enable Nitro Enclaves"
  type        = bool
  default     = false
}

variable "nodegroup_taints" {
  description = "Taints for the nodegroup"
  type = map(object({
    key    = string
    value  = string
    effect = string
  }))
  default = {
    dedicated = {
      key    = "kms_dedicated"
      value  = "true"
      effect = "NO_SCHEDULE"
    }
  }
}

variable "nodegroup_additional_security_group_ids" {
  description = "List of additional security group IDs to associate with the node group"
  type        = list(string)
  default     = []
}

variable "nodegroup_enable_ssm_managed_instance" {
  description = "Whether to enable SSM managed instance"
  type        = bool
  default     = false
}

variable "nodegroup_use_latest_ami_release_version" {
  description = "Whether to use the latest AMI release version"
  type        = bool
  default     = false
}

variable "nodegroup_ami_release_version" {
  description = "AMI release version for the nodegroup"
  type        = string
  default     = "1.32.3-20250620"
}

# kms configuration (need to be updated if upgrade to new zama-kms image)
variable "kms_image_attestation_sha" {
  description = "Attestation SHA for KMS image"
  type        = string
}

variable "kms_enabled_nitro_enclaves" {
  description = "Whether to enable KMS for Nitro Enclaves"
  type        = bool
  default     = false
}

variable "kms_deletion_window_in_days" {
  description = "Deletion window in days for KMS key"
  type        = number
  default     = 30
}

# RDS Configuration
variable "enable_rds" {
  description = "Whether to enable RDS"
  type        = bool
  default     = false
}

variable "rds_db_name" {
  description = "Name of the RDS database"
  type        = string
  default     = "kms-connector"
}

variable "rds_manage_master_user_password" {
  description = "Whether to manage the master user password"
  type        = bool
  default     = false
}

variable "rds_engine" {
  description = "Engine for the RDS database"
  type        = string
  default     = "postgres"
}

variable "rds_engine_version" {
  description = "Engine version for the RDS database"
  type        = string
  default     = "17.2"
}

variable "rds_instance_class" {
  description = "Instance class for the RDS database"
  type        = string
  default     = "db.t3.medium"
}

variable "rds_allocated_storage" {
  description = "Allocated storage for the RDS database"
  type        = number
  default     = 50
}

variable "rds_max_allocated_storage" {
  description = "Maximum allocated storage for the RDS database"
  type        = number
  default     = 100
}

variable "rds_multi_az" {
  description = "Whether to enable multi-AZ for the RDS database"
  type        = bool
  default     = false
}

variable "rds_backup_retention_period" {
  description = "Backup retention period for the RDS database"
  type        = number
  default     = 7
}

variable "rds_maintenance_window" {
  description = "Maintenance window for the RDS database"
  type        = string
  default     = "sun:05:00-sun:08:00"
}

variable "rds_monitoring_interval" {
  description = "Monitoring interval for the RDS database"
  type        = number
  default     = 60
}

variable "rds_monitoring_role_arn" {
  description = "ARN of the monitoring role for the RDS database"
  type        = string
  default     = null
}

variable "rds_performance_insights_enabled" {
  description = "Whether to enable performance insights for the RDS database"
  type        = bool
  default     = false
}

variable "rds_performance_insights_kms_key_id" {
  description = "KMS key ID for performance insights"
  type        = string
  default     = null
}

variable "rds_performance_insights_retention_period" {
  description = "Retention period for performance insights"
  type        = number
  default     = 7
}

variable "rds_blue_green_update_enabled" {
  description = "Whether to enable blue-green update for the RDS database"
  type        = bool
  default     = false
}

variable "use_eks_cluster_authentication" {
  description = "Whether to use EKS cluster authentication"
  type        = bool
  default     = false
}

variable "rds_parameters" {
  description = "Parameters for the RDS database"
  type        = list(map(string))
  default     = []
}

variable "rds_snapshot_identifier" {
  description = "Snapshot identifier for the RDS database"
  type        = string
  default     = null
}

variable "rds_final_snapshot_enabled" {
  description = "Whether to enable final snapshot for the RDS database"
  type        = bool
  default     = false
}

variable "rds_k8s_secret_name" {
  description = "Name of the Kubernetes secret for the RDS database"
  type        = string
  default     = "rds-credentials"
}

variable "rds_k8s_secret_namespace" {
  description = "Namespace of the Kubernetes secret for the RDS database"
  type        = string
  default     = "mpc-party"
}

variable "rds_allowed_cidr_blocks" {
  description = "Allowed CIDR blocks for the RDS database"
  type        = list(string)
  default     = []
}

variable "rds_vpc_id" {
  description = "VPC ID for the RDS database"
  type        = string
  default     = null
}

variable "rds_subnet_ids" {
  description = "Subnet IDs for the RDS database"
  type        = list(string)
  default     = []
}