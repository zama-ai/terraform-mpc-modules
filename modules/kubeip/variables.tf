# Core Configuration
variable "name" {
  type        = string
  description = "Name for the KubeIP deployment"
  default     = "kubeip"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "namespace" {
  type        = string
  description = "Kubernetes namespace for KubeIP deployment"
  default     = "kube-system"
}

# KubeIP Configuration
variable "kubeip_image" {
  type        = string
  description = "KubeIP container image - Official DoIT International image"
  default     = "doitintl/kubeip-agent"
}

variable "kubeip_version" {
  type        = string
  description = "KubeIP container image version"
  default     = "latest"
}

variable "image_pull_policy" {
  type        = string
  description = "Image pull policy for KubeIP container"
  default     = "IfNotPresent"
  
  validation {
    condition     = contains(["Always", "IfNotPresent", "Never"], var.image_pull_policy)
    error_message = "Image pull policy must be one of: Always, IfNotPresent, Never."
  }
}

# Service Account Configuration
variable "create_service_account" {
  type        = bool
  description = "Whether to create a service account for KubeIP"
  default     = true
}

variable "service_account_name" {
  type        = string
  description = "Name of the service account for KubeIP"
  default     = "kubeip-service-account"
}

variable "service_account_labels" {
  type        = map(string)
  description = "Additional labels for the service account"
  default     = {}
}

# IRSA Configuration
variable "enable_irsa" {
  type        = bool
  description = "Whether to enable IAM Roles for Service Accounts (IRSA)"
  default     = true
}

# Elastic IP Filtering Configuration
variable "eip_filter_tags" {
  type        = string
  description = "Filter for Elastic IPs using AWS tags (e.g., 'Name=tag:kubeip,Values=reserved;Name=tag:environment,Values=production')"
}

# Logging Configuration
variable "log_level" {
  type        = string
  description = "Log level for KubeIP agent (debug, info, warn, error)"
  default     = "info"
  
  validation {
    condition     = contains(["debug", "info", "warn", "error"], var.log_level)
    error_message = "Log level must be one of: debug, info, warn, error."
  }
}

# Node Targeting Configuration
variable "target_node_labels" {
  type        = map(string)
  description = "Node labels for KubeIP to target specific nodes"
  default = {
    "kubeip" = "use"
  }
}

# Pod and DaemonSet Configuration
variable "daemonset_labels" {
  type        = map(string)
  description = "Additional labels for the DaemonSet"
  default     = {}
}

variable "pod_labels" {
  type        = map(string)
  description = "Additional labels for KubeIP pods"
  default     = {}
}

variable "pod_annotations" {
  type        = map(string)
  description = "Additional annotations for KubeIP pods"
  default     = {}
}

variable "node_selector" {
  type        = map(string)
  description = "Node selector for KubeIP pods (targets specific nodes)"
  default     = {}
}

variable "additional_tolerations" {
  type = list(object({
    key                = optional(string)
    operator           = optional(string, "Equal")
    value              = optional(string)
    effect             = string
    toleration_seconds = optional(number)
  }))
  description = "Additional tolerations for KubeIP pods (default system tolerations are automatically applied)"
  default     = []
}

# Resource Configuration (based on official example)
variable "resource_requests" {
  type = map(string)
  description = "Resource requests for KubeIP containers"
  default = {
    cpu    = "10m"
    memory = "32Mi"
  }
}

variable "resource_limits" {
  type = map(string)
  description = "Resource limits for KubeIP containers"
  default = {
    cpu    = "100m"
    memory = "64Mi"
  }
}

# Environment Variables
variable "environment_variables" {
  type        = map(string)
  description = "Additional environment variables for KubeIP container"
  default     = {}
}

# Common Tags
variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to AWS resources"
  default     = {}
}