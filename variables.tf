# Core Configuration
variable "name_prefix" {
  type        = string
  description = "Prefix for all resource names"
  default     = "mpc"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster where MPC infrastructure will be deployed"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)"
  default     = "dev"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the node group. If empty, will use all cluster subnets. Should be public subnets for internet connectivity."
  default     = null
}



variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for the node group. If not specified, the EKS cluster's Kubernetes version will be used"
  default     = null
}

# Node Group Configuration
variable "nodegroup_min_size" {
  type        = number
  description = "Minimum number of nodes in the enclave node group"
  default     = 1
}

variable "nodegroup_max_size" {
  type        = number
  description = "Maximum number of nodes in the enclave node group"
  default     = 3
}

variable "nodegroup_desired_size" {
  type        = number
  description = "Desired number of nodes in the enclave node group"
  default     = 1
}

variable "nodegroup_instance_types" {
  type        = list(string)
  description = "List of instance types for the enclave node group"
  default     = ["t3.large"]
}

variable "nodegroup_capacity_type" {
  type        = string
  description = "Type of capacity associated with the EKS Node Group. Valid values: ON_DEMAND, SPOT"
  default     = "ON_DEMAND"
  
  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.nodegroup_capacity_type)
    error_message = "Capacity type must be either ON_DEMAND or SPOT."
  }
}

variable "nodegroup_ami_type" {
  type        = string
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group"
  default     = "AL2_x86_64"
}

variable "nodegroup_disk_size" {
  type        = number
  description = "Disk size in GiB for enclave nodes"
  default     = 50
}

variable "nodegroup_labels" {
  type        = map(string)
  description = "Additional Kubernetes labels for the enclave nodes"
  default     = {}
}

variable "nodegroup_taints" {
  type = map(object({
    key    = string
    value  = string
    effect = string
  }))
  description = "Additional Kubernetes taints for the enclave nodes"
  default     = {}
}

variable "nodegroup_tags" {
  type        = map(string)
  description = "Additional tags for the node group"
  default     = {}
}

variable "nodegroup_additional_security_group_ids" {
  type        = list(string)
  description = "Additional security group IDs for the enclave nodes"
  default     = []
}

# Remote Access Configuration
variable "enable_remote_access" {
  type        = bool
  description = "Whether to enable SSH access to the enclave nodes"
  default     = false
}

variable "ec2_ssh_key" {
  type        = string
  description = "EC2 Key Pair name for SSH access to enclave nodes"
  default     = null
}

variable "source_security_group_ids" {
  type        = list(string)
  description = "List of security group IDs allowed for SSH access"
  default     = []
}

# Firewall Configuration
variable "enable_dedicated_security_group" {
  type        = bool
  description = "Whether to create and use a dedicated security group for enclave nodes"
  default     = true
}

variable "mpc_p2p_ports" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
  }))
  description = "List of P2P ports for MPC communication"
  default = [
    {
      from_port   = 50001
      to_port     = 50001
      protocol    = "tcp"
      description = "MPC P2P TCP"
    },
    {
      from_port   = 50100
      to_port     = 50100
      protocol    = "tcp"
      description = "MPC grpc port"
    },
    {
      from_port   = 9646
      to_port     = 9646
      protocol    = "tcp"
      description = "MPC metrics port"
    }
  ]
}

variable "allowed_peer_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks allowed to access MPC P2P ports (other MPC participants)"
  default     = []
}

variable "allowed_peer_security_groups" {
  type        = list(string)
  description = "List of security group IDs allowed to access MPC P2P ports"
  default     = []
}

variable "additional_security_group_rules" {
  type = list(object({
    type                     = string
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    source_security_group_id = optional(string)
    description              = optional(string)
  }))
  description = "Additional security group rules for the enclave nodes"
  default     = []
}

variable "firewall_tags" {
  type        = map(string)
  description = "Additional tags for firewall resources"
  default     = {}
}

# KubeIP Configuration
variable "kubeip_namespace" {
  type        = string
  description = "Kubernetes namespace for KubeIP deployment"
  default     = "kube-system"
}

variable "kubeip_version" {
  type        = string
  description = "KubeIP container image version"
  default     = "latest"
}


variable "kubeip_target_node_labels" {
  type        = map(string)
  description = "Node labels for KubeIP to target specific nodes"
  default = {
    "kubeip" = "use"
  }
}

variable "kubeip_node_selector" {
  type        = map(string)
  description = "Additional node selector for KubeIP pods"
  default     = {}
}

variable "kubeip_log_level" {
  type        = string
  description = "Log level for KubeIP agent (debug, info, warn, error)"
  default     = "info"
  
  validation {
    condition     = contains(["debug", "info", "warn", "error"], var.kubeip_log_level)
    error_message = "Log level must be one of: debug, info, warn, error."
  }
}

variable "kubeip_additional_tolerations" {
  type = list(object({
    key                = optional(string)
    operator           = optional(string, "Equal")
    value              = optional(string)
    effect             = string
    toleration_seconds = optional(number)
  }))
  description = "Additional tolerations for KubeIP pods (beyond the default system tolerations)"
  default     = []
}

variable "kubeip_resource_requests" {
  type = map(string)
  description = "Resource requests for KubeIP containers"
  default = {
    cpu    = "10m"
    memory = "32Mi"
  }
}

variable "kubeip_resource_limits" {
  type = map(string)
  description = "Resource limits for KubeIP containers"
  default = {
    cpu    = "100m"
    memory = "64Mi"
  }
}

variable "kubeip_tags" {
  type        = map(string)
  description = "Additional tags for KubeIP resources"
  default     = {}
}

# Common Tags
variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to all resources"
  default     = {}
}

variable "kubeip_eip_filter_tags" {
  type        = map(string)
  description = "Map of AWS tags to filter Elastic IPs for KubeIP assignment (e.g., { kubeip = 'reserved', environment = 'prod' })"
  default = {
    kubeip = "reserved"
  }
}

variable "kubeconfig_path" {
  type        = string
  description = "Path to the kubeconfig file"
  default     = "~/.kube/config"
}

variable "kubeconfig_context" {
  type        = string
  description = "Context to use in the kubeconfig file"
}

variable "nodegroup_enable_public_access" {
  type        = bool
  description = "Whether to enable public access to the enclave nodes"
  default     = false
}