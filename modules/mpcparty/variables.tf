variable "network_environment" {
  description = "MPC network environment that determines region constraints"
  type        = string
  default     = "testnet"
  validation {
    condition     = contains(["testnet", "mainnet"], var.network_environment)
    error_message = "Network environment must be either 'testnet' or 'mainnet'."
  }
}

variable "testnet_supported_regions" {
  description = "AWS regions supported by the MPC party for testnet"
  type        = list(string)
  default     = ["eu-west-1"]
}

variable "mainnet_supported_regions" { 
  description = "AWS regions supported by the MPC party for mainnet"
  type        = list(string)
  default     = ["eu-west-1"]
}

variable "enable_region_validation" {
  type        = bool
  description = "Whether to enable region validation"
  default     = true
}

# S3 Bucket Configuration
variable "vault_private_bucket_name" {
  type        = string
  description = "The name of the S3 bucket for private MPC party storage"
}

variable "vault_public_bucket_name" {
  type        = string
  description = "The name of the S3 bucket for public MPC party storage"
}

# MPC Party Configuration
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
  description = "Name of the ConfigMap (defaults to 'mpc-party-config-{party_name}' if not provided)"
  default     = null
}

variable "additional_config_data" {
  type        = map(string)
  description = "Additional key-value pairs to add to the ConfigMap"
  default     = {}
}

# Tagging
variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to all AWS resources"
  default = {
    "terraform" = "true"
    "module"    = "mpcparty"
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

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for the node group. If not specified, the EKS cluster's Kubernetes version will be used"
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
  default     = 10
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
  default     = ["t3.large"]
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

# Launch Template Configuration
variable "nodegroup_use_custom_launch_template" {
  type        = bool
  description = "Whether to use a custom launch template"
  default     = true
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

# Labels and Taints
variable "nodegroup_labels" {
  type        = map(string)
  description = "Key-value map of Kubernetes labels applied to the node group"
  default     = {}
}

variable "nodegroup_taints" {
  type        = map(object({
    key    = string
    value  = string
    effect = string
  }))
  description = "Map of Kubernetes taints to apply to the node group"
  default     = {}
}

# Tags
variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource"
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
  type        = string
  description = "Customer master key spec for KMS"
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

variable "nodegroup_enable_ssm_managed_instance" {
  type        = bool
  description = "Whether to enable SSM managed instance"
  default     = false
}