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
  default     = "kms-decentralized"
}

variable "create_namespace" {
  description = "Whether to create the namespace if it doesn't exist"
  type        = bool
  default     = true
}

variable "party_id" {
  description = "Party ID for the MPC service"
  type        = string
}

variable "sync_public_bucket" {
  description = "Sync public bucket between partners"
  type = object({
    enabled        = optional(bool, true)
    configmap_name = optional(string, "mpc-party")
  })
  default = {
    enabled        = true
    configmap_name = "mpc-party"
  }
}

variable "partner_name" {
  description = "Partner name for the MPC service"
  type        = string
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

variable "kubernetes_nlb_extra_labels" {
  description = "Extra labels to add to the Kubernetes NLB"
  type        = map(string)
  default     = {}
}

variable "enable_grpc_port" {
  description = "Whether to enable and expose the gRPC port in the load balancer service"
  type        = bool
  default     = true
}
