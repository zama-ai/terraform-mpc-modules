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



