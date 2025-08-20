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
  description = "AWS regions supported by the VPC endpoint consumer for testnet"
  type        = list(string)
  default     = ["eu-west-1"]
}

variable "mainnet_supported_regions" { 
  description = "AWS regions supported by the VPC endpoint consumer for mainnet"
  type        = list(string)
  default     = ["eu-west-1"]
}

variable "enable_region_validation" {
  type        = bool
  description = "Whether to enable region validation"
  default     = true
}

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

variable "party_services" {
  description = "List of partner MPC services to connect to via VPC interface endpoints"
  type = list(object({
    name                      = string # Name of the partner service
    region                    = string # AWS region where the partner service is located  
    account_id                = optional(string, null) # AWS account ID where the partner service is located (optional)
    partner_name              = optional(string, null) # Name of the partner name (optional)
    vpc_endpoint_service_name = string # VPC endpoint service name (required - AWS-generated name)
    ports = optional(list(object({
      name        = string
      port        = number
      target_port = number
      protocol    = string
    })), null)
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

# Default MPC Port Configurations
variable "default_mpc_ports" {
  description = "Default port configurations for MPC services. These can be overridden per service in party_services configuration."
  type = object({
    grpc = object({
      name        = string
      port        = number
      target_port = number
      protocol    = string
    })
    peer = object({
      name        = string
      port        = number
      target_port = number
      protocol    = string
    })
    metrics = object({
      name        = string
      port        = number
      target_port = number
      protocol    = string
    })
  })
  default = {
    grpc = {
      name        = "grpc"
      port        = 50100
      target_port = 50100
      protocol    = "TCP"
    }
    peer = {
      name        = "peer"
      port        = 50001
      target_port = 50001
      protocol    = "TCP"
    }
    metrics = {
      name        = "metrics"
      port        = 9646
      target_port = 9646
      protocol    = "TCP"
    }
  }
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