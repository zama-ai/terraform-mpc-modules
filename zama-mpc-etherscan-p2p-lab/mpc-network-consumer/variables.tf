variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "eu-west-1"
}

variable "aws_profile" {
  description = "AWS profile to use for authentication"
  type        = string
  default     = "token-zws-dev"
}

# MPC Cluster Configuration
variable "cluster_name" {
  description = "Name of the MPC cluster"
  type        = string
  default     = "consumer-mpc-cluster"
}

variable "namespace" {
  description = "Kubernetes namespace for partner services"
  type        = string
  default     = "kms-decentralized"
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

variable "use_eks_cluster_authentication" {
  description = "Whether to use EKS cluster authentication"
  type        = bool
  default     = false
}

# Direct VPC Configuration (Mode 2)
variable "vpc_id" {
  description = "VPC ID where VPC interface endpoints will be created (required when use_eks_cluster_lookup is false)"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Subnet IDs where VPC interface endpoints will be created (required when use_eks_cluster_lookup is false)"
  type        = list(string)
  default     = null
}

variable "security_group_ids" {
  description = "Security group IDs for VPC interface endpoints (optional when use_eks_cluster_lookup is false)"
  type        = list(string)
  default     = null
}

# Partner Services Configuration
variable "party_services" {
  description = "List of partner services to connect to"
  type = list(object({
    name                      = string
    region                    = string
    party_id                  = string
    account_id                = optional(string)
    partner_name              = optional(string)
    vpc_endpoint_service_name = string
    ports = optional(list(object({
      name        = string
      port        = number
      target_port = number
      protocol    = string
    })), [])
    availability_zones  = optional(list(string), null) # miss this params before fixed
    create_kube_service = optional(bool, true)
    kube_service_config = optional(object({
      additional_annotations = optional(map(string), {})
      labels                 = optional(map(string), {})
      session_affinity       = optional(string, "None")
    }), {})
  }))
  default = []
}

# VPC Endpoint Configuration
variable "private_dns_enabled" {
  description = "Whether to enable private DNS for VPC endpoints"
  type        = bool
  default     = true
}

variable "name_prefix" {
  description = "Prefix for naming VPC endpoints and related resources"
  type        = string
  default     = "mpc-partner"
}

# Timeouts
variable "endpoint_create_timeout" {
  description = "Timeout for creating VPC endpoints"
  type        = string
  default     = "15m"
}

variable "endpoint_delete_timeout" {
  description = "Timeout for deleting VPC endpoints"
  type        = string
  default     = "10m"
}

# Custom DNS Configuration
variable "create_custom_dns_records" {
  description = "Whether to create custom DNS records for VPC interface endpoints"
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
  default     = "mpc-partners.internal"
}

# Tagging
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    "terraform" = "true"
  }
}
