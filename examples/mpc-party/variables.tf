# AWS Configuration
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-west-2"
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
  description = "Whether to create the Kubernetes namespace (handled by mpcparty module)"
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