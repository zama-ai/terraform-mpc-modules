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

variable "aws_region" {
  description = "AWS region"
  type        = string
}

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

  validation {
    condition     = length(var.mpc_services) > 0
    error_message = "At least one MPC service must be defined."
  }
}

variable "service_create_timeout" {
  description = "Timeout for creating Kubernetes services"
  type        = string
  default     = "10m"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
} 