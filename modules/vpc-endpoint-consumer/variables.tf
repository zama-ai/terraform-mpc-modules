# ==============================================================================
# VPC Endpoint Consumer Module - Variables
# ==============================================================================
# 
# This module supports two configuration modes for network setup:
#
# MODE 1: EKS Cluster Lookup (Recommended for EKS deployments)
# -------------------------------------------------------------
# Automatically retrieves VPC, subnet, and security group details from an 
# existing EKS cluster. This is the recommended approach when connecting to
# partner services from an EKS-based MPC cluster.
#
# Required variables:
# - cluster_name: Name of the EKS cluster to lookup
#
# Example:
#   cluster_name = "my-mpc-cluster"
#   # vpc_id, subnet_ids, security_group_ids are automatically retrieved
#
# MODE 2: Direct Specification (Custom network configuration)
# -----------------------------------------------------------
# Manually specify VPC, subnet, and security group details. Use this mode
# when you need custom network configuration or when not using EKS.
#
# Required variables:
# - vpc_id: VPC ID where endpoints will be created
# - subnet_ids: List of subnet IDs for the endpoints
#
# Optional variables:
# - security_group_ids: List of security group IDs (defaults to cluster SGs if not provided)
#
# Example:
#   vpc_id = "vpc-0123456789abcdef0"
#   subnet_ids = ["subnet-abc123", "subnet-def456"]
#   security_group_ids = ["sg-abc123"]  # Optional
#
# KUBERNETES SERVICES:
# -------------------
# Kubernetes services are created individually based on each partner service's 
# create_kube_service flag. Set create_kube_service = false for specific services
# to skip Kubernetes service creation for those services.
#
# IMPORTANT: Only use ONE network mode at a time. The module includes validation to
# prevent conflicts between the two modes.
# ==============================================================================

# Network Configuration - Choose one of two modes:
# Mode 1: EKS Cluster Lookup - provide cluster_name
# Mode 2: Direct Specification - provide vpc_id, subnet_ids, security_group_ids

variable "cluster_name" {
  description = "Name of the EKS cluster to lookup VPC, subnet, and security group details (Mode 1). If provided, vpc_id, subnet_ids, and security_group_ids will be ignored."
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC ID where the VPC interface endpoints will be created (Mode 2). Required if cluster_name is not provided."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet IDs where the VPC interface endpoints will be created (Mode 2). Required if cluster_name is not provided."
  type        = list(string)
  default     = null
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with the VPC interface endpoints (Mode 2). Required if cluster_name is not provided."
  type        = list(string)
  default     = null
}

# Internal validation variable to ensure network configuration is correct
variable "configuration_mode_validation" {
  description = "Internal variable for validation - do not set manually"
  type        = string
  default     = "auto"
  
  validation {
    condition = var.configuration_mode_validation == "auto" && (
      # Mode 1: cluster_name provided
      (var.cluster_name != null && var.cluster_name != "") ||
      # Mode 2: vpc_id, subnet_ids provided (security_group_ids optional)
      (var.vpc_id != null && var.vpc_id != "" && var.subnet_ids != null && length(coalesce(var.subnet_ids, [])) > 0)
    )
    error_message = "Either 'cluster_name' OR ('vpc_id' + 'subnet_ids') must be provided."
  }

  validation {
    condition = var.configuration_mode_validation == "auto" && !(
      (var.cluster_name != null && var.cluster_name != "") &&
      (var.vpc_id != null && var.vpc_id != "")
    )
    error_message = "Cannot provide both 'cluster_name' and 'vpc_id'. Choose either EKS cluster lookup OR direct VPC specification."
  }
}

variable "party_services" {
  description = "List of partner MPC services to connect to via VPC interface endpoints"
  type = list(object({
    name                      = string # Name of the partner service
    region                    = string # AWS region where the partner service is located  
    account_id                = optional(string, null) # AWS account ID where the partner service is located (optional)
    partner_name              = optional(string, null) # Name of the partner name (optional)
    vpc_endpoint_service_name = string # VPC endpoint service name (required - AWS-generated name)
    ports = list(object({
      name        = string
      port        = number
      target_port = number
      protocol    = string
    }))
    create_kube_service = optional(bool, true) # Whether to create Kubernetes service
    kube_service_config = optional(object({
      additional_annotations  = optional(map(string), {})
      labels                  = optional(map(string), {})
      session_affinity        = optional(string, "None")
    }), {})
  }))

  validation {
    condition     = length(var.party_services) > 0
    error_message = "At least one partner service must be defined."
  }

  validation {
    condition = alltrue([
      for service in var.party_services : 
      service.vpc_endpoint_service_name != null && service.vpc_endpoint_service_name != ""
    ])
    error_message = "vpc_endpoint_service_name is required for all partner services and must be the actual AWS-generated VPC endpoint service name (e.g., 'com.amazonaws.vpce.region.vpce-svc-xxxxx')."
  }
}

variable "endpoint_policy" {
  description = "IAM policy document for the VPC interface endpoints in JSON format"
  type        = string
  default     = null
}

variable "private_dns_enabled" {
  description = "Whether to enable private DNS for the VPC interface endpoints"
  type        = bool
  default     = false
}

variable "route_table_ids" {
  description = "List of route table IDs to associate with the VPC interface endpoints"
  type        = list(string)
  default     = []
}

variable "name_prefix" {
  description = "Prefix for naming VPC interface endpoint resources"
  type        = string
  default     = "mpc-partner"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "additional_tags" {
  description = "Additional tags to apply to VPC interface endpoint resources"
  type        = map(string)
  default     = {}
}

variable "endpoint_create_timeout" {
  description = "Timeout for creating VPC interface endpoints"
  type        = string
  default     = "10m"
}

variable "endpoint_delete_timeout" {
  description = "Timeout for deleting VPC interface endpoints"
  type        = string
  default     = "10m"
}

# Kubernetes-related variables
variable "namespace" {
  description = "Kubernetes namespace where partner services will be created"
  type        = string
  default     = "mpc-partners"
}

variable "create_namespace" {
  description = "Whether to create the namespace if it doesn't exist"
  type        = bool
  default     = false
}

# Custom DNS variables
variable "create_custom_dns_records" {
  description = "Whether to create custom DNS records for the VPC interface endpoints"
  type        = bool
  default     = false
}

variable "private_zone_id" {
  description = "Route53 private hosted zone ID for custom DNS records"
  type        = string
  default     = ""
}

variable "dns_domain" {
  description = "DNS domain for custom DNS records"
  type        = string
  default     = "mpc-partners.local"
} 