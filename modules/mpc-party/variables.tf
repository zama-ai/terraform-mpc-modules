variable "network_environment" {
  description = "MPC network environment that determines region constraints"
  type        = string
  default     = "testnet"
  validation {
    condition     = contains(["testnet", "mainnet"], var.network_environment)
    error_message = "Network environment must be either 'testnet' or 'mainnet'."
  }
}




variable "bucket_prefix" {
  type        = string
  description = "The prefix for the S3 bucket names"
  default     = "mpc-vault"
}


# MPC Party Configuration
variable "party_id" {
  description = "Party ID for the MPC service"
  type        = string
}

variable "party_name" {
  type        = string
  description = "The name of the MPC party (used for resource naming and tagging)"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.party_name))
    error_message = "Party name must contain only lowercase letters, numbers, and hyphens."
  }
}

# EKS Cluster Configuration
variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster for IRSA configuration"
}

# Kubernetes Namespace Configuration
variable "k8s_namespace" {
  type        = string
  description = "The Kubernetes namespace for MPC party resources"
  default     = "kms-decentralized"
}

variable "create_namespace" {
  type        = bool
  description = "Whether to create the Kubernetes namespace"
  default     = true
}

variable "namespace_labels" {
  type        = map(string)
  description = "Additional labels to apply to the namespace"
  default     = {}
}

variable "namespace_annotations" {
  type        = map(string)
  description = "Additional annotations to apply to the namespace"
  default     = {}
}

# Kubernetes Service Account Configuration
variable "k8s_service_account_name" {
  type        = string
  description = "The name of the Kubernetes service account for MPC party"
}

variable "create_service_account" {
  type        = bool
  description = "Whether to create the Kubernetes service account (should be false when using IRSA as IRSA creates it)"
  default     = true
}

variable "service_account_labels" {
  type        = map(string)
  description = "Additional labels to apply to the service account"
  default     = {}
}

variable "service_account_annotations" {
  type        = map(string)
  description = "Additional annotations to apply to the service account (excluding IRSA annotations which are handled automatically)"
  default     = {}
}

# IRSA Configuration
variable "create_irsa" {
  type        = bool
  description = "Whether to create IRSA (IAM Roles for Service Accounts) role for secure AWS access"
  default     = true
}

# ConfigMap Configuration
variable "create_config_map" {
  type        = bool
  description = "Whether to create a ConfigMap with S3 bucket environment variables"
  default     = true
}

variable "config_map_name" {
  type        = string
  description = "Name of the ConfigMap"
  default     = "mpc-party"
}


# Deprecated Tagging
variable "common_tags" {
  type        = map(string)
  description = "Deprecated common tags to apply to all AWS resources"
  default = {
    "terraform" = "true"
    "module"    = "mpc-party"
  }
}

# Tagging
variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource"
  default = {
    "terraform" = "true"
    "module"    = "mpc-party"
  }
}

# EKS Node Group Core Configuration
variable "create_nodegroup" {
  type        = bool
  description = "Whether to create an EKS managed node group"
  default     = false
}

variable "nodegroup_name" {
  type        = string
  description = "Name of the EKS managed node group"
}


variable "nodegroup_use_latest_ami_release_version" {
  type        = bool
  description = "Whether to use the latest AMI release version"
  default     = false
}


variable "nodegroup_ami_release_version" {
  type        = string
  description = "AMI release version for the node group"
  default     = null
  //validation {
  //  condition     = contains(["1.32.3-20250620"], var.nodegroup_ami_release_version)
  //  error_message = "This AMI release version is not supported. Please use the recommended version in the list."
  //}
}

variable "nodegroup_ami_id" {
  type        = string
  description = "AMI ID for the node group. When set, uses a custom AMI. When null, uses EKS-optimized AMI based on ami_type and ami_release_version"
  default     = null
}

# Scaling Configuration
variable "nodegroup_min_size" {
  type        = number
  description = "Minimum number of instances in the node group"
  default     = 1
}

variable "nodegroup_max_size" {
  type        = number
  description = "Maximum number of instances in the node group"
  default     = 1
}

variable "nodegroup_desired_size" {
  type        = number
  description = "Desired number of instances in the node group"
  default     = 1
}

# Instance Configuration
variable "nodegroup_instance_types" {
  type        = list(string)
  description = "List of instance types for the node group"
  default     = ["c7a.16xlarge"]
}

variable "nodegroup_capacity_type" {
  type        = string
  description = "Type of capacity associated with the EKS Node Group. Valid values: ON_DEMAND, SPOT"
  default     = "ON_DEMAND"
}

variable "nodegroup_ami_type" {
  type        = string
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group"
  default     = "AL2_x86_64"
}

variable "nodegroup_disk_size" {
  type        = number
  description = "Disk size in GiB for worker nodes"
  default     = 20
}


# Remote Access Configuration
variable "nodegroup_enable_remote_access" {
  type        = bool
  description = "Whether to enable remote access to the worker nodes"
  default     = false
}

variable "nodegroup_ec2_ssh_key" {
  type        = string
  description = "EC2 Key Pair name that provides access for SSH communication with the worker nodes"
  default     = null
}

variable "nodegroup_source_security_group_ids" {
  type        = list(string)
  description = "List of security group IDs allowed for remote access"
  default     = []
}


variable "nodegroup_additional_security_group_ids" {
  type        = list(string)
  description = "List of additional security group IDs to associate with the node group"
  default     = []
}

# Labels
variable "nodegroup_labels" {
  type        = map(string)
  description = "Key-value map of Kubernetes labels applied to the node group"
  default     = {}
}

# Nitro Enclaves Configuration
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

variable "nodegroup_enable_nitro_enclaves" {
  type        = bool
  description = "Whether to enable Nitro Enclaves"
}

variable "nodegroup_nitro_enclaves_image_repo" {
  type        = string
  description = "Image repository for Nitro Enclaves"
  default     = "public.ecr.aws/aws-nitro-enclaves/aws-nitro-enclaves-k8s-device-plugin"
}

variable "nodegroup_nitro_enclaves_image_tag" {
  type        = string
  description = "Image tag for Nitro Enclaves"
  default     = "v0.3"
}

variable "nodegroup_nitro_enclaves_daemonset_additional_envs" {
  type        = map(string)
  description = "Additional environment variables to add to the Nitro Enclaves daemonset"
  default     = {}
}

variable "nodegroup_nitro_enclaves_daemonset_resources" {
  type = object({
    limits   = map(string)
    requests = map(string)
  })
  description = "Resources for the Nitro Enclaves daemonset"
  default = {
    limits = {
      cpu    = "100m"
      memory = "30Mi"
    }
    requests = {
      cpu    = "10m"
      memory = "15Mi"
    }
  }
}

variable "nodegroup_nitro_enclaves_daemonset_enabled" {
  type        = bool
  description = "Whether to enable the Nitro Enclaves daemonset"
  default     = true
}

variable "nodegroup_auto_assign_security_group" {
  type        = bool
  description = "The auto-resolver retrieves the node group security group from the cluster security group and assigns it to the node group. This variable is can be used if the cluster have additional security groups that allow traffic from the node group to the cluster API server on port 443(created by the EKS module https://registry.terraform.io/modules/terraform-aws-modules/eks)."
  default     = true
}

variable "nodegroup_update_config" {
  type = object({
    max_unavailable            = optional(number)
    max_unavailable_percentage = optional(number)
  })
  description = "Update config for the node group (use either max_unavailable or max_unavailable_percentage as they are mutually exclusive)"
  default = {
    max_unavailable            = 1
    max_unavailable_percentage = null
  }
}


# kms configuration
variable "kms_enabled_nitro_enclaves" {
  type        = bool
  description = "Whether to enable KMS for Nitro Enclaves"
}

variable "kms_key_usage" {
  type        = string
  description = "Key usage for KMS"
  default     = "ENCRYPT_DECRYPT"
}

variable "kms_customer_master_key_spec" {
  description = "Specification for the KMS customer master key (e.g., SYMMETRIC_DEFAULT, RSA_2048)"
  type        = string
  default     = "SYMMETRIC_DEFAULT"
}

variable "kms_image_attestation_sha" {
  type        = string
  description = "Attestation SHA for KMS image"
}

variable "kms_deletion_window_in_days" {
  type        = number
  description = "Deletion window in days for KMS key"
  default     = 30
}

variable "kms_enable_backup_vault" {
  type        = bool
  description = "Whether to enable the backup vault for the KMS key"
  default     = false
}

variable "kms_backup_external_role_arn" {
  type        = string
  description = "ARN of the backup vault for the KMS key"
  default     = null
}



variable "kms_backup_vault_key_usage" {
  type        = string
  description = "Key usage for the backup vault"
  default     = "ENCRYPT_DECRYPT"
}

variable "kms_backup_vault_customer_master_key_spec" {
  type        = string
  description = "Key spec for the backup vault"
  default     = "ASYMMETRIC_DEFAULT"
}


variable "nodegroup_enable_ssm_managed_instance" {
  type        = bool
  description = "Whether to enable SSM managed instance"
  default     = false
}


# ******************************************************
# variables for the RDS instance
# ******************************************************
variable "enable_rds" {
  type        = bool
  description = "Whether to create the RDS instance"
  default     = true
}

variable "rds_prefix" {
  description = "Name organization prefix (e.g., 'zama')."
  type        = string
  default     = "zama"
}

variable "rds_vpc_id" {
  description = "VPC ID hosting the RDS instance."
  type        = string
  default     = null
}

variable "rds_allowed_cidr_blocks" {
  description = "CIDR blocks allowed to reach the database port."
  type        = list(string)
  default     = []
}

variable "rds_engine" {
  type        = string
  description = "Engine name (e.g., postgres, mysql)."
  default     = "postgres"
}

variable "rds_engine_version" {
  type        = string
  description = "Exact engine version string."
  default     = "17.2"
}

variable "rds_instance_class" {
  type        = string
  description = "DB instance class (e.g., db.t4g.medium)."
  default     = "db.t4g.medium"
}

variable "rds_allocated_storage" {
  type        = number
  description = "Allocated storage in GiB."
  default     = 50
}

variable "rds_max_allocated_storage" {
  type        = number
  description = "Max autoscaled storage in GiB."
  default     = 100
}

variable "rds_db_name" {
  type        = string
  default     = "kmsconnector"
  description = "Optional initial database name."
}

variable "rds_backup_retention_period" {
  description = "Number of days to retain RDS automated backups (0 to 35)"
  type        = number
  default     = 7
}

variable "rds_maintenance_window" {
  description = "Weekly maintenance window for RDS instance (e.g., 'sun:05:00-sun:06:00')"
  type        = string
  default     = null
}

variable "rds_multi_az" {
  description = "Whether to enable Multi-AZ deployment for RDS instance for high availability"
  type        = bool
  default     = false
}

variable "rds_deletion_protection" {
  description = "Whether to enable deletion protection for RDS instance"
  type        = bool
  default     = false
}

variable "rds_db_password" {
  description = "RDS password to be set from inputs (must be longer than 8 chars), will disable RDS automatic SecretManager password"
  type        = string
  default     = null
}

variable "rds_enable_master_password_rotation" {
  description = "Whether to manage the master user password rotation. By default, false on creation, rotation is managed by RDS. There is not currently no way to disable this on initial creation even when set to false. Setting this value to false after previously having been set to true will disable automatic rotation."
  type        = bool
  default     = true
}

variable "rds_master_password_rotation_days" {
  description = "Number of days between automatic scheduled rotations of the secret, default is set to the maximum allowed value of 1000 days"
  type        = number
  default     = 1000
}

variable "rds_monitoring_interval" {
  description = "Enhanced monitoring interval in seconds (0, 1, 5, 10, 15, 30, 60)"
  type        = number
  default     = 0
}

variable "rds_monitoring_role_arn" {
  description = "ARN of IAM role for RDS enhanced monitoring (required if monitoring_interval > 0)"
  type        = string
  default     = null
}

# Parameter group
variable "rds_parameters" {
  description = "List of DB parameter maps for the parameter group."
  type        = list(map(string))
  # Required by KMS-Connector which currently lacks ssl certificates
  default = [{
    name  = "rds.force_ssl"
    value = "0"
  }]
}


variable "rds_create_externalname_service" {
  description = "Whether to create a Kubernetes ExternalName service for RDS database access"
  type        = bool
  default     = false
}

variable "rds_externalname_service_name" {
  description = "Name of the Kubernetes ExternalName service for RDS database"
  type        = string
  default     = "kms-connector-db-external"
}

variable "rds_externalname_service_namespace" {
  description = "Kubernetes namespace for the RDS ExternalName service"
  type        = string
  default     = "default"
}

# Optional override for RDS identifier
variable "rds_identifier_override" {
  type        = string
  default     = null
  description = "Explicit DB identifier. If null, a normalized name is derived from prefix+environment+identifier."
}

variable "rds_port" {
  type        = number
  default     = 5432
  description = "Port for the RDS instance"
}

variable "rds_username" {
  type        = string
  default     = "zws"
  description = "Username for the RDS instance"
}

variable "rds_create_monitoring_role" {
  type        = bool
  default     = true
  description = "Whether to create the RDS monitoring role"
}
