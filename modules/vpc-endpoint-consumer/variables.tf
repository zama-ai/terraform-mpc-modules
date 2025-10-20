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
  description = "List of security group IDs to associate with the VPC interface endpoints (Mode 2). Required if cluster_name is not provided and create_security_group is false."
  type        = list(string)
  default     = null
}

variable "create_security_group" {
  description = "Whether to create a security group for VPC endpoints with default ingress rules"
  type        = bool
  default     = false
}

variable "security_group_name" {
  description = "Name of the security group to create (if create_security_group is true)"
  type        = string
  default     = "mpc-vpc-endpoint-consumer-sg"
}

variable "security_group_description" {
  description = "Description for the security group"
  type        = string
  default     = "Security group for MPC VPC endpoint consumer"
}

variable "security_group_ingress_cidr_blocks" {
  description = "CIDR blocks to allow ingress traffic from for MPC ports (when create_security_group is true)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "security_group_ingress_source_sg_id" {
  description = "Source security group ID to allow ingress traffic from for MPC ports (when create_security_group is true). If set, this takes precedence over cidr_blocks."
  type        = string
  default     = null
}

variable "party_services" {
  description = "List of partner MPC services to connect to via VPC interface endpoints"
  type = list(object({
    name                      = string
    region                    = string
    party_id                  = string
    account_id                = optional(string, null)
    partner_name              = optional(string, null)
    vpc_endpoint_service_name = string
    public_bucket_url         = optional(string, null)
    ports = optional(list(object({
      name        = string
      port        = number
      target_port = number
      protocol    = string
    })), null)
    availability_zones  = optional(list(string), null)
    create_kube_service = optional(bool, true)
    kube_service_config = optional(object({
      additional_annotations = optional(map(string), {})
      labels                 = optional(map(string), {})
      session_affinity       = optional(string, "None")
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

variable "tags" {
  description = "Tags to apply to VPC interface endpoint resources"
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
  default     = "kms-decentralized"
}

variable "create_namespace" {
  description = "Whether to create the namespace if it doesn't exist"
  type        = bool
  default     = false
}

variable "enable_grpc_port" {
  description = "Whether to enable and expose the gRPC port in the load balancer service"
  type        = bool
  default     = true
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
