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

variable "aws_profile" {
  description = "AWS profile to use for authentication"
  type        = string
  default     = "token-zws-dev"
}

# MPC Party Configuration
variable "party_id" {
  description = "Party ID for the MPC service"
  type        = number
}

variable "party_name" {
  description = "Name of the MPC party (used for tagging and resource naming)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.party_name))
    error_message = "Party name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "config_map_name" {
  description = "Name of the ConfigMap"
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
  default     = "kms-decentralized"
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

variable "nodegroup_name" {
  description = "Name of the nodegroup"
  type        = string
  default     = "mpc-party-nodegroup"
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

variable "nitro_enclaves_override_cpu_count" {
  type        = number
  description = "Override the CPU count for Nitro Enclaves"
  default     = null
}


variable "nitro_enclaves_override_memory_mib" {
  type        = number
  description = "Override the memory for Nitro Enclaves"
  default     = null
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

variable "nodegroup_ami_id" {
  description = "AMI ID for the nodegroup"
  type        = string
  default     = "ami-0efe6ddc452e87d71"
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
  default     = "kmsconnector"
}


variable "rds_username" {
  description = "Username for the RDS database"
  type        = string
  default     = "kmsconnector"
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
  default     = 0
}

variable "rds_deletion_protection" {
  description = "Whether to enable deletion protection for the RDS database"
  type        = bool
  default     = true
}

variable "rds_monitoring_role_arn" {
  description = "ARN of the monitoring role for the RDS database"
  type        = string
  default     = null
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

variable "rds_create_monitoring_role" {
  description = "Whether to create the RDS monitoring role"
  type        = bool
  default     = true
}
