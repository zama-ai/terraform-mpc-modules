# MPC Cluster Configuration
variable "cluster_name" {
  description = "Name of the MPC cluster"
  type        = string
  default     = "mpc-cluster"
}

variable "deployment_mode" {
  description = "Deployment mode: 'provider' (create NLBs and optionally VPC endpoints) or 'consumer' (connect to existing partner services via VPC interface endpoints)"
  type        = string
  default     = "provider"

  validation {
    condition     = contains(["provider", "consumer"], var.deployment_mode)
    error_message = "Deployment mode must be either 'provider' or 'consumer'."
  }
}

variable "namespace" {
  description = "Kubernetes namespace where MPC services will be deployed"
  type        = string
  default     = "mpc-cluster"
}

variable "create_namespace" {
  description = "Whether to create the namespace if it doesn't exist"
  type        = bool
  default     = true
}

# MPC Services Configuration
variable "mpc_services" {
  description = "List of MPC services to create with their configurations"
  type = list(object({
    name = string
    ports = list(object({
      name        = string
      port        = number
      target_port = any
      protocol    = string
      node_port   = optional(number)
    }))
    selector                    = map(string)
    additional_annotations      = optional(map(string), {})
    labels                      = optional(map(string), {})
    session_affinity            = optional(string, "None")
    external_traffic_policy     = optional(string, "Cluster")
    internal_traffic_policy     = optional(string, "Cluster")
    load_balancer_source_ranges = optional(list(string), [])
  }))

  # Note: Validation depends on deployment_mode context
  # In provider mode: at least one service required
  # In consumer mode: can be empty (connects to external services)
}

# VPC Endpoints Configuration
variable "create_vpc_endpoints" {
  description = "Whether to create VPC endpoints for the NLBs"
  type        = bool
  default     = false
}

variable "vpc_endpoints_config" {
  description = "Configuration for VPC endpoint services (provider side)"
  type = object({
    acceptance_required = optional(bool, false)
    allowed_principals  = optional(list(string), [])
    supported_regions   = optional(list(string), [])
  })
  default = {
    acceptance_required = false
    allowed_principals  = []
    supported_regions   = []
  }
}

# Timeouts and Performance Configuration
variable "service_create_timeout" {
  description = "Timeout for creating Kubernetes services"
  type        = string
  default     = "5m"
}

# Tagging
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    "terraform" = "true"
    "module"    = "mpc-cluster"
  }
}

# Consumer Mode Network Configuration (for deployment mode = "consumer")
# Choose one of two modes:
# Mode 1: EKS Cluster Lookup - provide consumer_cluster_name
# Mode 2: Direct Specification - provide consumer_vpc_id, consumer_subnet_ids, consumer_security_group_ids

variable "consumer_cluster_name" {
  description = "Name of the EKS cluster to lookup VPC, subnet, and security group details for consumer mode (Mode 1). If provided, consumer network variables will be ignored."
  type        = string
  default     = null
}

variable "consumer_vpc_id" {
  description = "VPC ID where VPC interface endpoints will be created for consumer mode (Mode 2). Required if consumer_cluster_name is not provided and deployment_mode is consumer."
  type        = string
  default     = null
}

variable "consumer_subnet_ids" {
  description = "List of subnet IDs where VPC interface endpoints will be created for consumer mode (Mode 2). Required if consumer_cluster_name is not provided and deployment_mode is consumer."
  type        = list(string)
  default     = null
}

variable "consumer_security_group_ids" {
  description = "List of security group IDs to associate with VPC interface endpoints for consumer mode (Mode 2). Optional - defaults to EKS cluster security groups."
  type        = list(string)
  default     = null
}

# Partner Services Configuration (for consumer mode)
variable "party_services_config" {
  description = "Configuration for connecting to partner MPC services via VPC interface endpoints"
  type = object({
    party_services = list(object({
      name                      = string
      region                    = string
      account_id                = optional(string, null)
      partner_name              = optional(string, null)
      vpc_endpoint_service_name = string
      ports = list(object({
        name        = string
        port        = number
        target_port = number
        protocol    = string
      }))
      create_kube_service = optional(bool, true)
      kube_service_config = optional(object({
        additional_annotations  = optional(map(string), {})
        labels                  = optional(map(string), {})
        session_affinity        = optional(string, "None")
      }), {})
    }))
    
    # VPC Endpoint Configuration
    endpoint_policy           = optional(string, null)
    private_dns_enabled       = optional(bool, true)
    route_table_ids           = optional(list(string), [])
    name_prefix               = optional(string, "mpc-partner")
    additional_tags           = optional(map(string), {})
    endpoint_create_timeout   = optional(string, "10m")
    endpoint_delete_timeout   = optional(string, "10m")
    
    # Kubernetes Configuration
    namespace                     = optional(string, "mpc-partners")
    create_namespace              = optional(bool, false)
    
    # Custom DNS Configuration
    create_custom_dns_records = optional(bool, false)
    private_zone_id           = optional(string, "")
    dns_domain                = optional(string, "mpc-partners.local")
  })
  default = {
    party_services = []
  }
}

# Validation for consumer mode network configuration
variable "consumer_network_validation" {
  description = "Internal variable for validation - do not set manually"
  type        = string
  default     = "auto"
  
  validation {
    condition = var.consumer_network_validation == "auto" && (var.deployment_mode != "consumer" || (
      # If deployment_mode is consumer, ensure network configuration is valid
      (var.consumer_cluster_name != null && var.consumer_cluster_name != "") ||
      (var.consumer_vpc_id != null && var.consumer_vpc_id != "" && 
       var.consumer_subnet_ids != null && length(coalesce(var.consumer_subnet_ids, [])) > 0)
    ))
    error_message = "For consumer mode, either 'consumer_cluster_name' OR ('consumer_vpc_id' + 'consumer_subnet_ids') must be provided."
  }

  validation {
    condition = var.consumer_network_validation == "auto" && (var.deployment_mode != "consumer" || !(
      (var.consumer_cluster_name != null && var.consumer_cluster_name != "") &&
      (var.consumer_vpc_id != null && var.consumer_vpc_id != "")
    ))
    error_message = "Cannot provide both 'consumer_cluster_name' and 'consumer_vpc_id'. Choose either EKS cluster lookup OR direct VPC specification."
  }
}
