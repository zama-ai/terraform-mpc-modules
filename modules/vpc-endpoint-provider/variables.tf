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
  description = "AWS regions supported by the VPC endpoint service for testnet"
  type        = list(string)
  default     = ["eu-west-1"]
}

variable "mainnet_supported_regions" { 
  description = "AWS regions supported by the VPC endpoint service for mainnet"
  type        = list(string)
  default     = ["eu-west-1"]
}

variable "enable_region_validation" {
  type        = bool
  description = "Whether to enable region validation"
  default     = true
}

variable "acceptance_required" {
  description = "Whether or not VPC endpoint connection requests to the service must be accepted by the service owner"
  type        = bool
  default     = false
}

variable "supported_regions" {
  description = "List of AWS regions supported by the VPC endpoint service"
  type        = list(string)
  default     = []
}

variable "allowed_principals" {
  description = "List of AWS principal ARNs allowed to discover and connect to the endpoint service. Use ['*'] to allow all principals"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to assign to the VPC endpoint services"
  type        = map(string)
  default     = {}
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

variable "cleanup_sg_rules_v1" {
  description = "Whether to cleanup security group rules for NLBs made by the native aws load balancer controller v1"
  type        = bool
  default     = false
}

variable "load_balancer_controller_version" {
  description = "Version of the load balancer controller to use"
  type        = string
  default     = "v2"
}


variable "mpc_services" {
  description = "List of MPC services to create with their configurations"
  type = list(object({
    name = string
    display_nlb_name = optional(string, null)
    ports = optional(list(object({
      name        = string
      port        = number
      target_port = any
      protocol    = string
      node_port   = optional(number)
    })), null)
    selector                    = map(string)
    additional_annotations      = optional(map(string), {})
    labels                      = optional(map(string), {})
    session_affinity            = optional(string, "None")
    external_traffic_policy     = optional(string, "Cluster")
    internal_traffic_policy     = optional(string, "Cluster")
    load_balancer_source_ranges = optional(list(string), [])
  }))

  validation {
    condition     = length(var.mpc_services) > 0
    error_message = "At least one MPC service must be defined."
  }
}

# Default MPC Port Configurations
variable "default_mpc_ports" {
  description = "Default port configurations for MPC services. These can be overridden per service in mpc_services configuration."
  type = object({
    grpc = object({
      name        = string
      port        = number
      target_port = any
      protocol    = string
    })
    peer = object({
      name        = string
      port        = number
      target_port = any
      protocol    = string
    })
    metrics = object({
      name        = string
      port        = number
      target_port = any
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

variable "service_create_timeout" {
  description = "Timeout for creating Kubernetes services"
  type        = string
  default     = "10m"
}