# Core Configuration
variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

# Network Configuration
variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs where the node group will be placed. If empty, will use all cluster subnets"
  default     = []
}
//
# Security Group Configuration for Node Groups
variable "create_node_security_group" {
  type        = bool
  description = "Whether to create a dedicated security group for the node group (recommended for hostPort workloads)"
  default     = false
}

variable "node_security_group_name" {
  type        = string
  description = "Name for the node security group. If not provided, will be generated from node group name"
  default     = ""
}

variable "node_security_group_description" {
  type        = string
  description = "Description for the node security group"
  default     = "Security group for EKS node group with hostPort restrictions"
}

variable "allowed_peer_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks allowed to access hostPort services (for P2P connections)"
  default     = []
}

variable "allowed_peer_security_groups" {
  type        = list(string)
  description = "List of security group IDs allowed to access hostPort services"
  default     = []
}

variable "p2p_ports" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
  }))
  description = "List of P2P ports to allow from trusted sources"
  default = [
    {
      from_port   = 4001
      to_port     = 4001
      protocol    = "tcp"
      description = "IPFS swarm TCP"
    },
    {
      from_port   = 4002
      to_port     = 4002
      protocol    = "udp"
      description = "IPFS swarm UDP"
    }
  ]
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
  description = "Additional security group rules to add to the node security group"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource"
  default     = {}
}

variable "name" {
  type        = string
  description = "Name of the security group"
  default     = "firewall-mpc"
}
