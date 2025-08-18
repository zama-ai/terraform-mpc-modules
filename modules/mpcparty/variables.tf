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

# Launch Template Configuration
variable "nodegroup_create_launch_template" {
  type        = bool
  description = "Whether to create a launch template for the node group"
  default     = false
}

variable "nodegroup_launch_template_id" {
  type        = string
  description = "ID of an existing launch template to use. If provided, create_launch_template will be ignored"
  default     = null
}

variable "nodegroup_launch_template_version" {
  type        = string
  description = "Launch template version to use. Can be version number, '$Latest', or '$Default'"
  default     = null
}

variable "nodegroup_launch_template_name" {
  type        = string
  description = "Name of the launch template. If not provided, a name will be generated"
  default     = null
}

variable "nodegroup_launch_template_description" {
  type        = string
  description = "Description of the launch template"
  default     = "Launch template for EKS managed node group"
}

# Instance Configuration for Launch Template
variable "image_id" {
  type        = string
  description = "AMI ID for the launch template. If not provided, latest EKS optimized AMI will be used"
  default     = null
}

variable "nodegroup_launch_template_instance_type" {
  type        = string
  description = "Instance type for the launch template. Cannot be used with instance_types in node group"
  default     = null
}

variable "key_name" {
  type        = string
  description = "Key pair name for SSH access to instances"
  default     = null
}

variable "nodegroup_security_group_ids" {
  type        = list(string)
  description = "List of security group IDs to associate with instances. Will be combined with cluster security group"
  default     = []
}

# Block Device Mappings
variable "block_device_mappings" {
  type = list(object({
    device_name = string
    ebs = optional(object({
      volume_size           = optional(number, 20)
      volume_type           = optional(string, "gp3")
      iops                  = optional(number)
      throughput            = optional(number)
      encrypted             = optional(bool, true)
      kms_key_id            = optional(string)
      delete_on_termination = optional(bool, true)
      snapshot_id           = optional(string)
    }))
    no_device    = optional(string)
    virtual_name = optional(string)
  }))
  description = "Block device mappings for the launch template"
  default = [
    {
      device_name = "/dev/xvda"
      ebs = {
        volume_size           = 20
        volume_type           = "gp3"
        encrypted             = true
        delete_on_termination = true
      }
    }
  ]
}

# Instance Metadata Options
variable "nodegroup_launch_template_metadata_options" {
  type = object({
    http_endpoint               = optional(string, "enabled")
    http_tokens                 = optional(string, "required")
    http_put_response_hop_limit = optional(number, 2)
    instance_metadata_tags      = optional(string, "disabled")
  })
  description = "Instance metadata options for the launch template"
  default = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "disabled"
  }
}

# User Data Configuration
variable "nodegroup_launch_template_user_data_base64" {
  type        = string
  description = "Base64-encoded user data for the launch template. If not provided, default EKS bootstrap user data will be used"
  default     = null
}

variable "nodegroup_enable_bootstrap_user_data" {
  type        = bool
  description = "Whether to enable default EKS bootstrap user data when using custom launch template"
  default     = true
}

variable "nodegroup_pre_bootstrap_user_data" {
  type        = string
  description = "User data commands to run before EKS bootstrap script"
  default     = ""
}

variable "nodegroup_post_bootstrap_user_data" {
  type        = string
  description = "User data commands to run after EKS bootstrap script"
  default     = ""
}

variable "nodegroup_bootstrap_extra_args" {
  type        = string
  description = "Additional arguments to pass to the EKS bootstrap script"
  default     = ""
}

# CPU and Credit Specification
variable "nodegroup_launch_template_cpu_options" {
  type = object({
    core_count       = optional(number)
    threads_per_core = optional(number)
    amd_sev_snp      = optional(string)
  })
  description = "CPU options for the launch template"
  default     = null
}

variable "nodegroup_launch_template_credit_specification" {
  type = object({
    cpu_credits = string
  })
  description = "Credit specification for burstable performance instances"
  default     = null
}

# Network Interfaces (alternative to security_group_ids)
variable "nodegroup_launch_template_network_interfaces" {
  type = list(object({
    associate_public_ip_address = optional(bool, false)
    delete_on_termination       = optional(bool, true)
    device_index               = optional(number, 0)
    security_groups            = optional(list(string))
    subnet_id                  = optional(string)
  }))
  description = "Network interfaces for the launch template. Cannot be used with security_group_ids"
  default     = []
}

# Additional Launch Template Settings
variable "node_group_launch_template_ebs_optimized" {
  type        = bool
  description = "Whether to enable EBS optimization"
  default     = true
}

variable "nodegroup_launch_template_monitoring" {
  type = object({
    enabled = bool
  })
  description = "Monitoring configuration for instances"
  default = {
    enabled = true
  }
}

# Removed placement variable as it is not supported by the EKS Node Group module
#variable "placement" {
#  type = object({
#    affinity          = optional(string)
#    availability_zone = optional(string)
#    group_name        = optional(string)
#    host_id           = optional(string)
#    tenancy           = optional(string)
#  })
#  description = "Placement configuration for instances"
#  default     = null
#}
#
#variable "tag_specifications" {
#  type = list(object({
#    resource_type = string
#    tags          = map(string)
#  }))
#  description = "Tag specifications for resources created by the launch template"
#  default     = []
#}
#
#