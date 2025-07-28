# AWS Configuration
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "eu-west-1"
}

variable "aws_region_for_eks" {
  description = "AWS region where the EKS cluster is located (for provider configuration)"
  type        = string
  default     = null
}

# Kubernetes Provider Configuration
variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "kubeconfig_context" {
  description = "Kubernetes context to use from the kubeconfig file"
  type        = string
  default     = ""
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster for token authentication"
  type        = string
  default     = null
}

# MPC Cluster Configuration
variable "cluster_name" {
  description = "Name of the MPC cluster"
  type        = string
  default     = "zama-dev.tp.enix.io-zws-dev"
}

variable "namespace" {
  description = "Kubernetes namespace for MPC services"
  type        = string
  default     = "kms-decentralized"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "zws-dev"
}

variable "owner" {
  description = "Owner of the resources for tagging purposes"
  type        = string
  default     = "zws-team"
}

# MPC Services Configuration
variable "mpc_services" {
  description = "List of MPC services to deploy"
  type = list(object({
    name = string
    ports = list(object({
      name        = string
      port        = number
      target_port = number
      protocol    = string
    }))
    selector = map(string)
    additional_annotations = optional(map(string), {})
    labels = optional(map(string), {})
  }))
  default = []
}

# VPC Endpoint Services Configuration
variable "create_vpc_endpoints" {
  description = "Whether to create VPC endpoint services to expose NLBs via PrivateLink"
  type        = bool
  default     = true
}

variable "allowed_vpc_endpoint_principals" {
  description = "List of AWS principal ARNs allowed to connect to the VPC endpoint services"
  type        = list(string)
  default     = []
}

variable "vpc_endpoint_acceptance_required" {
  description = "Whether VPC endpoint connections require manual acceptance"
  type        = bool
  default     = false
}

variable "vpc_endpoint_supported_regions" {
  description = "List of AWS regions supported by the VPC endpoint services"
  type        = list(string)
  default     = ["eu-west-3"]
}

# Custom DNS Configuration
variable "create_custom_dns" {
  description = "Whether to create custom DNS records for VPC endpoints"
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
  default     = "mpc.internal"
}

# Tagging
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
} 